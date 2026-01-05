import 'package:upsessions/features/contacts/domain/liked_musician.dart';

import 'musician_entity.dart';

extension MusicianEntityToLikedMusician on MusicianEntity {
  LikedMusician toLikedMusician() {
    return LikedMusician(
      id: id,
      ownerId: ownerId,
      name: name,
      instrument: instrument,
      city: city,
      styles: styles,
      photoUrl: photoUrl,
      experienceYears: experienceYears,
    );
  }
}
