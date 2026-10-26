import 'dart:io';
import 'dart:typed_data';

import 'package:baptist_hymnal/audio/midi_file.dart';
import 'package:baptist_hymnal/data/hymn_audio.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _chunk(String tag, List<int> body) => Uint8List.fromList([
      ...tag.codeUnits,
      body.length >> 24 & 0xFF,
      body.length >> 16 & 0xFF,
      body.length >> 8 & 0xFF,
      body.length & 0xFF,
      ...body,
    ]);

void main() {
  test('applies tempo and orders note ends before starts at the same time', () {
    final bytes = Uint8List.fromList([
      // Format 1, two tracks, 480 ticks per quarter note.
      ..._chunk('MThd', [0, 1, 0, 2, 0x01, 0xE0]),
      // Tempo track: 60 bpm (1,000,000 microseconds per quarter note).
      ..._chunk('MTrk', [0x00, 0xFF, 0x51, 0x03, 0x0F, 0x42, 0x40, 0x00, 0xFF, 0x2F, 0x00]),
      ..._chunk('MTrk', [
        0x00, 0x90, 60, 100, // C4 on at 0
        0x83, 0x60, 62, 90, // running status: D4 on at 480
        0x00, 60, 0, // running status: C4 off (velocity 0) at 480
        0x83, 0x60, 0x80, 62, 64, // D4 off at 960
        0x00, 0xFF, 0x2F, 0x00,
      ]),
    ]);

    final midi = MidiFile.parse(bytes);

    expect(
      midi.events
          .map((e) => (e.timeMicros, e.key, e.isNoteOn))
          .toList(),
      [
        (0, 60, true),
        (1000000, 60, false),
        (1000000, 62, true),
        (2000000, 62, false),
      ],
    );
    expect(midi.durationMicros, 2000000);
  });

  test('rejects data that is not a MIDI file', () {
    expect(() => MidiFile.parse(Uint8List.fromList('RIFF0000'.codeUnits)),
        throwsFormatException);
  });

  test('reads a bundled hymn tune with every note ended', () {
    final path = englishHymnAudioAsset(1)!;
    final midi = MidiFile.parse(File(path).readAsBytesSync());

    expect(midi.events, isNotEmpty);
    expect(midi.durationMicros, inInclusiveRange(10e6, 300e6));
    final sounding = <(int, int)>{};
    for (final e in midi.events) {
      if (e.isNoteOn) {
        sounding.add((e.channel, e.key));
      } else {
        sounding.remove((e.channel, e.key));
      }
    }
    expect(sounding, isEmpty);
  });

  test('every listed hymn tune exists and parses', () {
    for (final id in englishHymnsWithAudio) {
      final midi = MidiFile.parse(File(englishHymnAudioAsset(id)!).readAsBytesSync());
      expect(midi.events, isNotEmpty, reason: 'hymn $id');
    }
  });
}
