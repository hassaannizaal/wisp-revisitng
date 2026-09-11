import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisp_mental_health/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('default points at the local backend', () {
      expect(AppConfig.defaultApiBaseUrl, 'http://localhost:5000/api');
    });

    test('falls back to the default when API_BASE_URL is absent', () {
      dotenv.testLoad(fileInput: '');
      expect(AppConfig.fromEnv().apiBaseUrl, AppConfig.defaultApiBaseUrl);
    });

    test('reads API_BASE_URL and strips a trailing slash', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.wisp.app/api/');
      expect(AppConfig.fromEnv().apiBaseUrl, 'https://api.wisp.app/api');
    });

    test('rejects a value that is not an absolute URL', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=not-a-url');
      expect(AppConfig.fromEnv, throwsArgumentError);
    });
  });
}
