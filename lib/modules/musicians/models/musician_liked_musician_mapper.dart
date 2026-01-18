import 'package:upsessions/features/contacts/models/liked_musician.dart';

import 'musician_entity.dart';

extension MusicianEntityToLikedMusician on MusicianEntity {
  LikedMusician toLikedMusician({
    String? highlightStyle,
    double? rating,
  }) {
    final resolvedHighlightStyle =
        (highlightStyle != null && highlightStyle.trim().isNotEmpty)
            ? highlightStyle
            : (styles.isNotEmpty ? styles.first : null);
    return LikedMusician(
      id: id,
      ownerId: ownerId,
      name: name,
      instrument: instrument,
      city: city,
      styles: styles,
      photoUrl: photoUrl,
      experienceYears: experienceYears,
      highlightStyle: resolvedHighlightStyle,
      rating: rating ?? this.rating,
    );
  }
}
