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
  // Where in the verse to start when [_restartOnResume] resumes.
  double _resumeWithin = 0;

  TuneState get state => _state;
  int? get hymnId => _hymnId;
  int get verseNumber => _verseIndex + 1;
  int get verseCount => _verseCount;
  double get speed => _speed;
  bool get repeat => _repeat;
  double get progress => _progress;

  /// How far into the whole hymn playback is, and how long the whole hymn
  /// takes, at the current speed.
  Duration get position => _atSpeed(_progress * _verseCount * _passMicros);
  Duration get duration => _atSpeed(_verseCount * _passMicros);

  bool get _ready => _state == TuneState.playing || _state == TuneState.paused;

  /// False on the last verse, unless repeat goes round to the first.
  bool get hasNextVerse =>
      _ready && (_verseIndex + 1 < _verseCount || _repeat);

  // Android: polls the native player for progress and the end of the tune.
  Timer? _statusPoll;
  Timer? _gapTimer;

  // The tune being played: its length on both platforms, and on iOS the
  // notes to schedule.
  MidiFile? _tune;
  (String, MidiFile)? _lastLoaded;

  // iOS: schedules notes from the parsed file.
  Timer? _ticker;
  final Stopwatch _clock = Stopwatch();
  int _tuneMicrosAtClockStart = 0;
  int _nextEvent = 0;
  final Set<(int, int)> _sounding = {};
  DateTime _lastNotify = DateTime.fromMillisecondsSinceEpoch(0);

  bool isPlayingHymn(int hymnId) =>
      _hymnId == hymnId && _state != TuneState.stopped;

  Future<void> play(
    int hymnId,
    String midiAsset, {
    int verses = 1,
    int startVerse = 0,
  }) async {
    await stop();
    _hymnId = hymnId;
    _midiAsset = midiAsset;
    _verseCount = verses < 1 ? 1 : verses;
    _verseIndex = startVerse.clamp(0, _verseCount - 1);
    _setState(TuneState.loading);
    try {
      final sfId = await (_soundfont ??= _loadSoundfont());
      final tune = await _load(midiAsset);
      if (_hymnId != hymnId) return; // stopped or replaced while loading
      _tune = tune;
      if (Platform.isIOS) {
        // Ads can take over the audio session, so claim it on every play.
        await _midi.configureAudioSession(mixWithOthers: false);
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
      _progress = _verseIndex / _verseCount;
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
      _clock
        ..stop()
        ..reset();
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
      await _restartTune(within: _resumeWithin);
      _resumeWithin = 0;
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
    _resumeWithin = 0;
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

  /// Moves to [fraction] of the way through the whole hymn.
  Future<void> seekTo(double fraction) async {
    if (!_ready) return;
    final at = fraction.clamp(0.0, 1.0) * _verseCount;
    final verse = at.floor().clamp(0, _verseCount - 1);
    await _jumpTo(verse, at - verse);
  }

  /// Starts [verse] (counting from 0) from its beginning.
  Future<void> playVerse(int verse) async {
    if (!_ready) return;
    await _jumpTo(verse.clamp(0, _verseCount - 1), 0);
  }

  Future<void> nextVerse() async {
    if (!hasNextVerse) return;
    await _jumpTo((_verseIndex + 1) % _verseCount, 0);
  }

  /// Back to the start of this verse, or to the verse before when already
  /// within a few seconds of the start.
  Future<void> previousVerse() async {
    if (!_ready) return;
    final intoVerse =
        _atSpeed((_progress * _verseCount - _verseIndex) * _passMicros);
    final back = intoVerse < const Duration(seconds: 3) && _verseIndex > 0;
    await _jumpTo(back ? _verseIndex - 1 : _verseIndex, 0);
  }

  /// How long one pass of [midiAsset] takes at normal speed.
  Future<Duration> passLength(String midiAsset) async =>
      Duration(microseconds: (await _load(midiAsset)).durationMicros);

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

  Future<MidiFile> _load(String midiAsset) async {
    final last = _lastLoaded;
    if (last != null && last.$1 == midiAsset) return last.$2;
    final data = await rootBundle.load(midiAsset);
    final tune = MidiFile.parse(data.buffer.asUint8List());
    _lastLoaded = (midiAsset, tune);
    return tune;
  }

  int get _passMicros => _tune?.durationMicros ?? 0;

  Duration _atSpeed(num micros) =>
      Duration(microseconds: (micros / _speed).round());

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

  /// Plays the current verse again from [within] (0 to 1) of the way in.
  Future<void> _restartTune({double within = 0}) async {
    final asset = _midiAsset;
    final loaded = _soundfont;
    if (asset == null || loaded == null || _hymnId == null) return;
    try {
      final sfId = await loaded;
      if (_state != TuneState.playing || _hymnId == null) return;
      if (Platform.isIOS) {
        _moveTicker(within);
        _startTicker(sfId);
      } else {
        await _midi.stopMidi();
        await _midi.loadMidiAsset(assetPath: asset, sfId: sfId);
        await _midi.setMidiTempo(_speed);
        await _midi.playMidi();
        // The player only knows the file's length once it is playing.
        if (within > 0) await _seekAndroid(within);
        _startStatusPoll();
      }
    } catch (e) {
      debugPrint('Next verse failed: $e');
      await stop();
    }
  }

  /// Moves to [within] (0 to 1) of the way through [verse], playing on from
  /// there if the tune was playing.
  Future<void> _jumpTo(int verse, double within) async {
    final hymnId = _hymnId;
    final loaded = _soundfont;
    if (hymnId == null || loaded == null || _tune == null) return;
    final passEnded = _betweenVerses || _restartOnResume;
    _gapTimer?.cancel();
    _betweenVerses = false;
    _restartOnResume = false;
    _verseIndex = verse;
    _progress = (verse + within) / _verseCount;
    notifyListeners();
    final playing = _state == TuneState.playing;
    try {
      final sfId = await loaded;
      if (Platform.isIOS) {
        _ticker?.cancel();
        await _releaseSounding();
        _moveTicker(within);
        if (playing) _startTicker(sfId);
      } else if (passEnded) {
        // The player has finished the last pass, so it needs loading again.
        if (playing) {
          await _restartTune(within: within);
        } else {
          _restartOnResume = true;
          _resumeWithin = within;
        }
      } else {
        _statusPoll?.cancel();
        await _seekAndroid(within);
        if (playing) _startStatusPoll();
      }
    } catch (e) {
      debugPrint('Moving in the tune failed: $e');
      if (_hymnId == hymnId) await stop();
    }
  }

  void _moveTicker(double within) {
    final tune = _tune!;
    _clock
      ..stop()
      ..reset();
    _tuneMicrosAtClockStart = (within * tune.durationMicros).round();
    final next =
        tune.events.indexWhere((e) => e.timeMicros >= _tuneMicrosAtClockStart);
    _nextEvent = next < 0 ? tune.events.length : next;
  }

  Future<void> _seekAndroid(double within) async {
    final status = await _midi.getMidiPlayerState();
    await _midi.seekMidi((within * status.totalTicks).round());
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
