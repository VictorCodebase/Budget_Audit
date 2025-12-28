import 'dart:math';

class FuzzySearch {
  /// Calculates the Levenshtein distance between two strings.
  /// Lower distance means more similar.
  static int levenshteinDistance(String s1, String s2) {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }

  /// Returns a list of strings from [candidates] that are similar to [query].
  /// [threshold] is the maximum allowed distance.
  static List<String> findSimilar(String query, List<String> candidates,
      {int threshold = 3}) {
    return candidates.where((candidate) {
      return levenshteinDistance(query, candidate) <= threshold;
    }).toList();
  }

  /// Returns the best match from [candidates] for [query], or null if none meet the [threshold].
  static String? findBestMatch(String query, List<String> candidates,
      {int threshold = 3}) {
    String? bestMatch;
    int bestDistance = threshold + 1;

    for (final candidate in candidates) {
      final distance = levenshteinDistance(query, candidate);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatch = candidate;
      }
    }

    return bestMatch;
  }
}
