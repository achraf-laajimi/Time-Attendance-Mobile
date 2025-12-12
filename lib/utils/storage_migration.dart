import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/global.dart';

class StorageMigration {

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static Future<bool> migrateTokenStorage(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;

      if (rememberMe) {
        final oldToken = prefs.getString(Global.TOKEN_KEY);

        if (oldToken != null && oldToken.isNotEmpty) {
          await _secureStorage.write(key: Global.TOKEN_KEY, value: oldToken);
          final verifyToken = await _secureStorage.read(key: Global.TOKEN_KEY);

          if (verifyToken != null) {
            await prefs.remove(Global.TOKEN_KEY);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Token migrated to secure storage successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error migrating token: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  static Future<bool> isMigrationNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldToken = prefs.getString(Global.TOKEN_KEY);
      final rememberMe = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;
      return oldToken != null && oldToken.isNotEmpty && rememberMe;
    } catch (e) {
      print("Error checking migration status: $e");
      return false;
    }
  }

  static Widget createMigrationButton(BuildContext context) {
    return FutureBuilder<bool>(
      future: isMigrationNeeded(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final migrationNeeded = snapshot.data ?? false;

        if (!migrationNeeded) {
          return const SizedBox.shrink();
        }

        return ElevatedButton(
          onPressed: () => migrateTokenStorage(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text("Migrate to Secure Storage"),
        );
      },
    );
  }

}