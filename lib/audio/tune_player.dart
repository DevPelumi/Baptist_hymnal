import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

import 'midi_file.dart';

enum TuneState { stopped, loading, playing, paused }

/// Plays hymn tunes (MIDI) through a bundled piano soundfont.
///
/// Android uses the synthesizer's own MIDI file player. iOS has no MIDI file
/// player in flutter_midi_pro, so there the notes are scheduled from Dart.
class TunePlayer extends ChangeNotifier with WidgetsBindingObserver {
  TunePlayer._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static final TunePlayer instance = TunePlayer._();

  static const String soundfontAsset = 'assets/soundfonts/piano.sf2';
  static const List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5];

  // Pause between verses when repeating, so singers can breathe.
  static const int _verseGapMicros = 800000;

  final MidiPro _midi = MidiPro();
  Future<int>? _soundfont;

  TuneState _state = TuneState.stopped;
  int? _hymnId;
  String? _midiAsset;
  int _verseCount = 1;
  int _verseIndex = 0;
  double _speed = 1.0;
  bool _repeat = false;
  double _progress = 0;
  bool _betweenVerses = false;
  bool _restartOnResume = false;

  TuneState get state => _state;
  int? get hymnId => _hymnId;
  int get verseNumber => _verseIndex + 1;
  int get verseCount => _verseCount;
  double get speed => _speed;
  bool get repeat => _repeat;
  double get progress => _progress;

  // Android: polls the native player for progress and the end of the tune.
  Timer? _statusPoll;
  Timer? _gapTimer;

  // iOS: schedules notes from the parsed file.
  MidiFile? _tune;
  Timer? _ticker;
  final Stopwatch _clock = Stopwatch();
  int _tuneMicrosAtClockStart = 0;
  int _nextEvent = 0;
  final Set<(int, int)> _sounding = {};
  DateTime _lastNotify = DateTime.fromMillisecondsSinceEpoch(0);

  bool isPlayingHymn(int hymnId) =>
      _hymnId == hymnId && _state != TuneState.stopped;

  Future<void> play(int hymnId, String midiAsset, {int verses = 1}) async {
    await stop();
    _hymnId = hymnId;
    _midiAsset = midiAsset;
    _verseCount = verses < 1 ? 1 : verses;
    _verseIndex = 0;
    _setState(TuneState.loading);
    try {
      final sfId = await (_soundfont ??= _loadSoundfont());
      if (_hymnId != hymnId) return; // stopped or replaced while loading
      if (Platform.isIOS) {
        // Ads can take over the audio session, so claim it on every play.
        await _midi.configureAudioSession(mixWithOthers: false);
        final data = await rootBundle.load(midiAsset);
        _tune = MidiFile.parse(data.buffer.asUint8List());
        _tuneMicrosAtClockStart = 0;
        _nextEvent = 0;
        _startTicker(sfId);
      } else {
        await _midi.loadMidiAsset(assetPath: midiAsset, sfId: sfId);
        await _midi.setMidiTempo(_speed);
        await _midi.setMidiLoop(1);
        await _midi.playMidi();
        _startStatusPoll();
      }
      if (_hymnId != hymnId) return;
      _progress = 0;
      _setState(TuneState.playing);
    } catch (e) {
      debugPrint('Tune playback failed: $e');
      await stop();
    }
  }

  Future<void> pause() async {
    if (_state != TuneState.playing) return;
    final duringGap = _betweenVerses;
    _gapTimer?.cancel();
    _betweenVerses = false;
    if (duringGap) {
      _restartOnResume = true;
      _setState(TuneState.paused);
      return;
    }
    if (Platform.isIOS) {
      _tuneMicrosAtClockStart = _tuneMicros;
      _clock.stop();
      _ticker?.cancel();
      await _releaseSounding();
    } else {
      _statusPoll?.cancel();
      await _midi.pauseMidi();
    }
    _setState(TuneState.paused);
  }

  Future<void> resume() async {
    if (_state != TuneState.paused) return;
    if (_restartOnResume) {
      _restartOnResume = false;
      _setState(TuneState.playing);
      await _restartTune();
      return;
    }
    final sfId = await _soundfont!;
    if (Platform.isIOS) {
      _startTicker(sfId);
    } else {
      await _midi.playMidi();
      _startStatusPoll();
    }
    _setState(TuneState.playing);
  }

  /// Stops playback, but only if [hymnId] (when given) is the one playing.
  Future<void> stop({int? hymnId}) async {
    if (hymnId != null && hymnId != _hymnId) return;
    final wasActive = _state != TuneState.stopped;
    _hymnId = null;
    _midiAsset = null;
    _verseIndex = 0;
    _verseCount = 1;
    _betweenVerses = false;
    _restartOnResume = false;
    _gapTimer?.cancel();
    _ticker?.cancel();
    _statusPoll?.cancel();
    _clock
      ..stop()
      ..reset();
    _tune = null;
    _progress = 0;
    if (wasActive && _midi.isInitialized) {
      try {
        if (Platform.isIOS) {
          await _releaseSounding();
        } else {
          await _midi.stopMidi();
        }
      } catch (e) {
        debugPrint('Stopping tune failed: $e');
      }
    }
    _setState(TuneState.stopped);
  }

  Future<void> setSpeed(double speed) async {
    if (Platform.isIOS) {
      _tuneMicrosAtClockStart = _tuneMicros;
      _clock.reset();
      if (_state == TuneState.playing) _clock.start();
    } else if (_state != TuneState.stopped) {
      await _midi.setMidiTempo(speed);
    }
    _speed = speed;
    notifyListeners();
  }

  Future<void> setRepeat(bool repeat) async {
    _repeat = repeat;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Dart timers stop in the background, which would leave notes hanging.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      pause();
    }
  }

  Future<int> _loadSoundfont() async {
    try {
      if (!_midi.isInitialized) {
        await _midi.init(bufferSize: 512);
        // The piano is a centred mono mix of a stereo soundfont, which plays
        // about 6 dB quieter than the original; make that up here.
        await _midi.setMasterGain(2.0);
      }
      return await _midi.loadSoundfontAsset(assetPath: soundfontAsset);
    } catch (_) {
      _soundfont = null; // let the next play try again
      rethrow;
    }
  }

  void _setState(TuneState state) {
    _state = state;
    notifyListeners();
  }

  void _startStatusPoll() {
    _statusPoll?.cancel();
    _statusPoll = Timer.periodic(const Duration(milliseconds: 250), (_) async {
      final status = await _midi.getMidiPlayerState();
      if (status.status == MidiPlayerStatus.done) {
        _onTuneEnded();
      } else if (_state == TuneState.playing && !_betweenVerses) {
        _progress = ((_verseIndex + status.progress) / _verseCount).clamp(0.0, 1.0);
        notifyListeners();
      }
    });
  }

  int get _tuneMicros =>
      _tuneMicrosAtClockStart + (_clock.elapsedMicroseconds * _speed).round();

  void _startTicker(int sfId) {
    _ticker?.cancel();
    _clock
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 5), (_) => _tick(sfId));
  }

  void _tick(int sfId) {
    final tune = _tune;
    if (tune == null) return;
    final now = _tuneMicros;
    final events = tune.events;
    while (_nextEvent < events.length && events[_nextEvent].timeMicros <= now) {
      final e = events[_nextEvent++];
      if (e.isNoteOn) {
        _sounding.add((e.channel, e.key));
        _midi.playNote(channel: e.channel, key: e.key, velocity: e.velocity, sfId: sfId);
      } else if (_sounding.remove((e.channel, e.key))) {
        _midi.stopNote(channel: e.channel, key: e.key, sfId: sfId);
      }
    }

    if (_nextEvent >= events.length && now >= tune.durationMicros) {
      _onTuneEnded();
      return;
    }

    // Progress only needs a few updates a second.
    final wall = DateTime.now();
    if (wall.difference(_lastNotify).inMilliseconds >= 200) {
      _lastNotify = wall;
      final within = (now / tune.durationMicros).clamp(0.0, 1.0);
      _progress = ((_verseIndex + within) / _verseCount).clamp(0.0, 1.0);
      notifyListeners();
    }
  }

  /// The file is one stanza. Play the next stanza after a breath, or stop.
  void _onTuneEnded() {
    if (_betweenVerses || _state != TuneState.playing) return;
    _statusPoll?.cancel();
    _ticker?.cancel();
    _clock.stop();
    final next = _verseIndex + 1;
    if (next >= _verseCount && !_repeat) {
      stop();
      return;
    }
    _verseIndex = next >= _verseCount ? 0 : next;
    _betweenVerses = true;
    _progress = _verseIndex / _verseCount;
    notifyListeners();
    _gapTimer = Timer(const Duration(microseconds: _verseGapMicros), () {
      _betweenVerses = false;
      if (_state != TuneState.playing) return;
      _restartTune();
    });
  }

  Future<void> _restartTune() async {
    final asset = _midiAsset;
    final loaded = _soundfont;
    if (asset == null || loaded == null || _hymnId == null) return;
    try {
      final sfId = await loaded;
      if (_state != TuneState.playing || _hymnId == null) return;
      if (Platform.isIOS) {
        _tuneMicrosAtClockStart = 0;
        _nextEvent = 0;
        _startTicker(sfId);
      } else {
        await _midi.stopMidi();
        await _midi.loadMidiAsset(assetPath: asset, sfId: sfId);
        await _midi.setMidiTempo(_speed);
        await _midi.playMidi();
        _startStatusPoll();
      }
    } catch (e) {
      debugPrint('Next verse failed: $e');
      await stop();
    }
  }

  Future<void> _releaseSounding() async {
    final sfId = await _soundfont;
    if (sfId == null) return;
    for (final (channel, key) in _sounding) {
      _midi.stopNote(channel: channel, key: key, sfId: sfId);
    }
    _sounding.clear();
  }
}
