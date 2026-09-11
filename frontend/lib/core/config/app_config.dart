import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typed, validated view over the values loaded from `.env`.
///
/// Reading configuration through one object (instead of `dotenv.env[...]`
/// scattered around the app) keeps every default and validation rule in a
/// single place and lets tests construct a config without a `.env` file.
class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  /// Builds the config from `.env`, falling back to the local backend.
  factory AppConfig.fromEnv() {
    final raw = dotenv.maybeGet('API_BASE_URL')?.trim();
    return AppConfig(apiBaseUrl: _normalizeBaseUrl(raw == null || raw.isEmpty ? defaultApiBaseUrl : raw));
  }

  static const defaultApiBaseUrl = 'http://localhost:5000/api';

  /// Base URL of the WISP API, without a trailing slash.
  final String apiBaseUrl;

  static String _normalizeBaseUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(url, 'API_BASE_URL', 'must be an absolute http(s) URL');
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnv());
