import 'dart:io';

class ConnectivityService {
  // Simple connectivity check
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Check connection to Supabase
  static Future<bool> canConnectToSupabase(String supabaseUrl) async {
    try {
      final uri = Uri.parse(supabaseUrl);
      final result = await InternetAddress.lookup(uri.host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

