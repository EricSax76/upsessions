import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/musicians/ui/utils/spotify_launcher.dart';

void main() {
  group('SpotifyLauncher.canLaunch', () {
    test('accepts spotify artist web urls from cloud function payload', () {
      expect(
        SpotifyLauncher.canLaunch(
          'https://open.spotify.com/artist/1Xyo4u8uXC1ZmMpatF05PJ',
        ),
        isTrue,
      );
    });

    test('accepts spotify deep links', () {
      expect(
        SpotifyLauncher.canLaunch('spotify:artist:1Xyo4u8uXC1ZmMpatF05PJ'),
        isTrue,
      );
    });

    test('rejects null, empty and non-spotify urls', () {
      expect(SpotifyLauncher.canLaunch(null), isFalse);
      expect(SpotifyLauncher.canLaunch('   '), isFalse);
      expect(SpotifyLauncher.canLaunch('foo'), isFalse);
      expect(
        SpotifyLauncher.canLaunch('https://example.com/artist/abc'),
        isFalse,
      );
    });
  });
}
