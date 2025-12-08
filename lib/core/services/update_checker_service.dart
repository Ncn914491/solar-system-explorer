import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Service to check for app updates from GitHub releases
class UpdateCheckerService {
  static const String _githubRepo = 'Ncn914491/solar-system-explorer';
  static const String _githubApiUrl =
      'https://api.github.com/repos/$_githubRepo/releases/latest';

  /// Checks if a new version is available
  /// Returns a map with update info or null if no update available
  Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Fetch latest release from GitHub
      final response = await http.get(Uri.parse(_githubApiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion =
            (data['tag_name'] as String).replaceFirst('v', '');
        final downloadUrl = _getApkDownloadUrl(data);

        // Compare versions
        if (_isNewerVersion(currentVersion, latestVersion)) {
          return {
            'currentVersion': currentVersion,
            'latestVersion': latestVersion,
            'downloadUrl': downloadUrl,
            'releaseNotes': data['body'] ?? '',
            'releaseName': data['name'] ?? 'New Version Available',
          };
        }
      }

      return null; // No update available
    } catch (e) {
      print('Error checking for updates: $e');
      return null;
    }
  }

  /// Extracts APK download URL from release assets
  String? _getApkDownloadUrl(Map<String, dynamic> releaseData) {
    try {
      final assets = releaseData['assets'] as List?;
      if (assets != null) {
        for (var asset in assets) {
          final name = asset['name'] as String;
          if (name.endsWith('.apk')) {
            return asset['browser_download_url'] as String;
          }
        }
      }
    } catch (e) {
      print('Error extracting APK URL: $e');
    }
    return null;
  }

  /// Compares two version strings
  /// Returns true if newVersion is newer than currentVersion
  bool _isNewerVersion(String currentVersion, String newVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final latest = newVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final currentPart = i < current.length ? current[i] : 0;
        final latestPart = i < latest.length ? latest[i] : 0;

        if (latestPart > currentPart) {
          return true;
        } else if (latestPart < currentPart) {
          return false;
        }
      }

      return false; // Versions are equal
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }

  /// Gets current app version
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0';
    }
  }
}
