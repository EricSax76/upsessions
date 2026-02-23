class AffinityFlow {
  const AffinityFlow._();

  static Map<String, List<String>> addInfluence({
    required Map<String, List<String>> influences,
    required String style,
    required String artist,
  }) {
    final normalizedStyle = style.trim();
    final normalizedArtist = artist.trim();
    if (normalizedStyle.isEmpty || normalizedArtist.isEmpty) {
      return influences;
    }

    final updated = Map<String, List<String>>.of(influences);
    final artists = List<String>.of(updated[normalizedStyle] ?? const []);
    final alreadyExists = artists.any(
      (current) => current.toLowerCase() == normalizedArtist.toLowerCase(),
    );
    if (alreadyExists) return influences;

    artists.add(normalizedArtist);
    updated[normalizedStyle] = artists;
    return updated;
  }

  static Map<String, List<String>> removeInfluence({
    required Map<String, List<String>> influences,
    required String style,
    required String artist,
  }) {
    final normalizedStyle = style.trim();
    final normalizedArtist = artist.trim();
    if (normalizedStyle.isEmpty || normalizedArtist.isEmpty) {
      return influences;
    }

    final updated = Map<String, List<String>>.of(influences);
    if (!updated.containsKey(normalizedStyle)) return influences;

    final artists = List<String>.of(updated[normalizedStyle]!);
    artists.removeWhere(
      (current) => current.toLowerCase() == normalizedArtist.toLowerCase(),
    );

    if (artists.isEmpty) {
      updated.remove(normalizedStyle);
    } else {
      updated[normalizedStyle] = artists;
    }
    return updated;
  }

  static bool isArtistSelected({
    required Map<String, List<String>> influences,
    required String style,
    required String artist,
  }) {
    final artists = influences[style] ?? const <String>[];
    return artists.any(
      (current) => current.toLowerCase() == artist.toLowerCase(),
    );
  }

  static List<String> filterSuggestions({
    required List<String> suggestions,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return suggestions;
    return suggestions
        .where((artist) => artist.toLowerCase().contains(normalizedQuery))
        .toList();
  }
}
