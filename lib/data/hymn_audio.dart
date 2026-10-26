/// How each English hymn uses its tune.
///
/// The MIDI file is one pass of the music. Play it once for each stanza.
/// [englishTunesWithRefrain] means that one pass already includes the refrain.
/// [englishTunesRefrainUnchecked] means the hymn has a refrain, but the music
/// file has no lyric map, so this could not be checked.
/// Every other tune with a file is one stanza. When that hymn also has a
/// refrain, the refrain is not in the file.
const Set<int> englishHymnsWithAudio = {
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72,
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
  85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108,
  109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
  122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133,
  134, 135, 136, 137, 139, 140, 141, 142, 143, 144, 145, 146,
  147, 148, 149, 150, 151, 152, 153, 155, 156, 157, 158, 159,
  160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171,
  172, 173, 174, 175, 176, 178, 179, 180, 181, 182, 183, 184,
  186, 187, 188, 190, 191, 192, 193, 194, 195, 196, 197, 198,
  199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
  211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222,
  223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234,
  235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 247,
  248, 249, 250, 251, 252, 254, 255, 256, 257, 258, 259, 260,
  261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272,
  273, 274, 275, 276, 277, 278, 280, 281, 282, 283, 284, 286,
  287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298,
  299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310,
  312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323,
  324, 326, 327, 328, 329, 334, 335, 336, 337, 339, 340, 341,
  343, 344, 345, 346, 349, 350, 351, 352, 353, 354, 355, 356,
  358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369,
  370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381,
  382, 383, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394,
  395, 396, 397, 398, 399, 400, 401, 402, 403, 405, 406, 407,
  408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419,
  420, 421, 422, 424, 425, 426, 427, 428, 429, 430, 432, 433,
  434, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447,
  448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459,
  460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471,
  472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483,
  484, 485, 488, 490, 491, 492, 493, 495, 496, 497, 498, 501,
  502, 503, 504, 505, 506, 507, 509, 510, 511, 512, 513, 514,
  515, 516, 522, 523, 524, 525, 529, 530, 531, 533, 534, 535,
  536, 538, 540, 541, 542, 555, 556, 557, 558, 559, 560, 561,
  562, 563, 566, 567, 569, 571, 572,
};

const Set<int> englishTunesWithRefrain = {
  87, 93, 95, 96, 97, 113, 125, 127, 131, 137, 139, 141,
  142, 144, 173, 181, 192, 194, 195, 196, 198, 199, 200, 201,
  202, 203, 204, 205, 207, 208, 209, 211, 212, 215, 216, 219,
  224, 225, 230, 233, 235, 236, 237, 238, 241, 256, 258, 259,
  260, 264, 265, 267, 269, 270, 272, 273, 274, 275, 283, 293,
  298, 301, 304, 305, 307, 310, 318, 319, 321, 334, 349, 352,
  361, 362, 363, 371, 389, 412, 419, 451, 455, 457, 463, 471,
  472, 473, 475, 478, 479, 481, 482, 483, 485, 488, 512,
};

const Set<int> englishTunesRefrainUnchecked = {
  88, 98, 106, 110, 119, 120, 130, 174, 175, 180, 184, 214,
  217, 218, 220, 222, 228, 231, 232, 239, 243, 271, 278, 299,
  300, 320, 326, 329, 350, 353, 364, 407, 408, 409, 410, 411,
  425, 429, 430, 432, 433, 437, 439, 469, 470, 474, 484, 509,
  559,
};

/// Asset path for [id], or null when this hymn has no matched tune.
String? englishHymnAudioAsset(int id) {
  if (!englishHymnsWithAudio.contains(id)) return null;
  return 'assets/audio/$id.mid';
}

/// True when one play includes the refrain, false when it is one stanza,
/// null when the file could not be checked.
bool? englishTuneIncludesRefrain(int id) {
  if (!englishHymnsWithAudio.contains(id)) return null;
  if (englishTunesWithRefrain.contains(id)) return true;
  if (englishTunesRefrainUnchecked.contains(id)) return null;
  return false;
}

/// Stanzas a singer fits to one play of the tune.
///
/// Hymn 542 keeps several different Amen settings in later blocks. Those
/// are not further stanzas of "The Lord Bless You and Keep You".
int englishHymnVerseCount(List<String> contents) {
  var numbered = 0;
  for (final block in contents) {
    var line = '';
    for (final part in block.split('\n')) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) {
        line = trimmed;
        break;
      }
    }
    if (RegExp(r'^\d+\.').hasMatch(line)) numbered++;
  }
  if (numbered == 0) return contents.isEmpty ? 1 : contents.length;
  return numbered;
}
