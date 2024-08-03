import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mbus/constants.dart';
import 'dart:typed_data';


class NetworkUtils {
  static ValueNotifier<bool> _networkError = new ValueNotifier(false);

  static addListener(VoidCallback callback) {
    _networkError.addListener(callback);
  }

  static createNetworkError() {
    _networkError.value = true;
  }
  static Future<String> getWithErrorHandling(BuildContext context, String url) async {
    try {
      final res = await http.get(Uri.parse("${BACKEND_URL}/${url}"));
      if (!res.persistentConnection) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Check internet connection.")));
        return "{}";
      } else if (res.statusCode != 200) {
        print(url);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
            "Error response from server. Please notify me through the contact form under the \"More\" tab on the bottom if this issue persists.")));
        return "{}";
      } else {
        if (_networkError.value) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
        _networkError.value = false;
        return res.body;
      }
    } catch (e) {
      if (!_networkError.value) {
        final thirtySeconds = Duration(seconds: 30);
        print("Exception: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Network error, check internet connection."),
              duration: thirtySeconds,));
        _networkError.value = true;
      }
      return "{}";
    }
  }
  static get hasNetworkError => _networkError.value;

  static Future<Uint8List?> getImageWithErrorHandling(BuildContext context, String url) async {
    final res = await http.get(Uri.parse("${BACKEND_URL}/${url}"));
    try {
      if (!res.persistentConnection) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Check internet connection.")));
        return null;
      } else if (res.statusCode != 200) {
        print(url);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
            "Error response from server. Please notify me through the contact form under the \"More\" tab on the bottom if this issue persists.")));
        return null;
      } else {
        if (_networkError.value) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
        _networkError.value = false;
        return res.bodyBytes;
      }
    } catch (e) {
      if (!_networkError.value) {
        final thirtySeconds = Duration(seconds: 30);
        print("Exception: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Network error, check internet connection."),
              duration: thirtySeconds,));
        _networkError.value = true;
      }
      return null;
    }
}
}