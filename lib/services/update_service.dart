import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:convert';

class UpdateService {
  static const String currentVersion = '1.4.0';
  static const String owner = 'anvar403inboxru-byte';
  static const String repo = 'salescrm-android';

  // GitHub Actions-dan ən son artifact APK linkini alır
  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/repos/$owner/$repo/releases/latest'),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
        if (latestVersion != currentVersion) {
          // APK asset-i tap
          final assets = data['assets'] as List;
          for (final asset in assets) {
            if ((asset['name'] as String).endsWith('.apk')) {
              return {
                'version': latestVersion,
                'downloadUrl': asset['browser_download_url'],
                'releaseNotes': data['body'] ?? '',
              };
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
    return null;
  }

  static Future<void> downloadAndInstall(
    BuildContext context,
    String downloadUrl,
    String version,
  ) async {
    final dir = await getTemporaryDirectory();
    final apkPath = '${dir.path}/orbitson_crm_$version.apk';

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _DownloadDialog(),
    );

    try {
      final response = await http.get(Uri.parse(downloadUrl));
      final file = File(apkPath);
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) Navigator.of(context).pop();
      await OpenFilex.open(apkPath);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yükləmə xətası: $e')),
        );
      }
    }
  }

  static Future<void> showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🚀 Yeni versiya mövcuddur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versiya: ${updateInfo['version']}'),
            const SizedBox(height: 8),
            if ((updateInfo['releaseNotes'] as String).isNotEmpty)
              Text(updateInfo['releaseNotes']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Sonra'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              downloadAndInstall(
                context,
                updateInfo['downloadUrl'],
                updateInfo['version'],
              );
            },
            child: const Text('Yenilə'),
          ),
        ],
      ),
    );
  }
}

class _DownloadDialog extends StatelessWidget {
  const _DownloadDialog();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('APK yüklənir...'),
        ],
      ),
    );
  }
}