import 'dart:typed_data';

/// A note starting or ending [timeMicros] after the start of the tune.
class MidiNoteEvent {
  const MidiNoteEvent(this.timeMicros, this.channel, this.key, this.velocity);

  final int timeMicros;
  final int channel;
  final int key;

  /// 0 for a note ending.
  final int velocity;

  bool get isNoteOn => velocity > 0;
}

/// The notes of a Standard MIDI File (format 0 or 1) with its tempo changes
/// applied, in playing order.
class MidiFile {
  MidiFile._(this.events, this.durationMicros);

  final List<MidiNoteEvent> events;
  final int durationMicros;

  factory MidiFile.parse(Uint8List bytes) {
    final reader = _Reader(bytes);
    if (reader.tag() != 'MThd') {
      throw const FormatException('Not a MIDI file');
    }
    final headerLength = reader.uint32();
    reader.uint16(); // format
    final trackCount = reader.uint16();
    final division = reader.uint16();
    if (division & 0x8000 != 0) {
      throw const FormatException('SMPTE time division is not supported');
    }
    reader.skip(headerLength - 6);

    final raw = <_RawEvent>[];
    for (var track = 0; track < trackCount && !reader.isDone; track++) {
      final tag = reader.tag();
      final length = reader.uint32();
      if (tag != 'MTrk') {
        reader.skip(length);
        continue;
      }
      _readTrack(_Reader(reader.bytes(length)), raw);
    }

    // At the same tick, tempo changes come first and note ends come before
    // note starts, so a repeated note is struck again rather than cut off.
    raw.sort((a, b) =>
        a.tick != b.tick ? a.tick - b.tick : a.order - b.order);

    final events = <MidiNoteEvent>[];
    var tempo = 500000; // microseconds per quarter note (120 bpm)
    var lastTick = 0;
    var micros = 0.0;
    for (final e in raw) {
      micros += (e.tick - lastTick) * tempo / division;
      lastTick = e.tick;
      if (e.tempo != null) {
        tempo = e.tempo!;
      } else if (e.key != null) {
        events.add(MidiNoteEvent(micros.round(), e.channel, e.key!, e.velocity));
      }
    }
    return MidiFile._(events, micros.round());
  }

  static void _readTrack(_Reader r, List<_RawEvent> out) {
    var tick = 0;
    var status = 0;
    while (!r.isDone) {
      tick += r.varInt();
      var byte = r.uint8();
      if (byte == 0xFF) {
        final type = r.uint8();
        final data = r.bytes(r.varInt());
        if (type == 0x51 && data.length == 3) {
          out.add(_RawEvent.tempo(tick, data[0] << 16 | data[1] << 8 | data[2]));
        } else if (type == 0x2F) {
          out.add(_RawEvent.end(tick));
          return;
        }
        continue;
      }
      if (byte == 0xF0 || byte == 0xF7) {
        r.skip(r.varInt());
        continue;
      }
      int data1;
      if (byte & 0x80 != 0) {
        status = byte;
        data1 = r.uint8();
      } else {
        data1 = byte; // running status
      }
      final channel = status & 0x0F;
      switch (status & 0xF0) {
        case 0x90:
          out.add(_RawEvent.note(tick, channel, data1, r.uint8()));
        case 0x80:
          r.uint8();
          out.add(_RawEvent.note(tick, channel, data1, 0));
        case 0xA0:
        case 0xB0:
        case 0xE0:
          r.uint8();
        case 0xC0:
        case 0xD0:
          break;
        default:
          throw FormatException('Unexpected MIDI status $status');
      }
    }
  }
}

class _RawEvent {
  _RawEvent.tempo(this.tick, this.tempo)
      : channel = 0,
        key = null,
        velocity = 0,
        order = 0;
  _RawEvent.note(this.tick, this.channel, int this.key, this.velocity)
      : tempo = null,
        order = velocity == 0 ? 1 : 2;
  _RawEvent.end(this.tick)
      : tempo = null,
        channel = 0,
        key = null,
        velocity = 0,
        order = 3;

  final int tick;
  final int? tempo;
  final int channel;
  final int? key;
  final int velocity;
  final int order;
}

class _Reader {
  _Reader(this._data);

  final Uint8List _data;
  int _pos = 0;

  bool get isDone => _pos >= _data.length;

  int uint8() {
    if (_pos >= _data.length) throw const FormatException('Truncated MIDI file');
    return _data[_pos++];
  }

  int uint16() => uint8() << 8 | uint8();

  int uint32() => uint16() << 16 | uint16();

  int varInt() {
    var value = 0;
    for (var i = 0; i < 4; i++) {
      final byte = uint8();
      value = value << 7 | (byte & 0x7F);
      if (byte & 0x80 == 0) return value;
    }
    throw const FormatException('Invalid variable-length number');
  }

  String tag() => String.fromCharCodes(bytes(4));

  Uint8List bytes(int length) {
    if (_pos + length > _data.length) {
      throw const FormatException('Truncated MIDI file');
    }
    final result = Uint8List.sublistView(_data, _pos, _pos + length);
    _pos += length;
    return result;
  }

  void skip(int length) => bytes(length);
}
