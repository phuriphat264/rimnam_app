import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// ── Base URL ─────────────────────────────────────────────────
// กำหนดใน dart_defines.json แล้วรันด้วย:
//   flutter run --dart-define-from-file=dart_defines.json
// Android emulator  → http://10.0.2.2:8000/api/v1
// iOS simulator     → http://localhost:8000/api/v1
// Physical device   → http://192.168.1.x:8000/api/v1  (IP เครื่อง dev, WiFi เดียวกัน)
const String kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.1.5:8000/api/v1',
);

const _kTimeout = Duration(seconds: 15);

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _client = http.Client();

  // ── Token helpers ─────────────────────────────────────────
  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() => _storage.deleteAll();

  Future<bool> isLoggedIn() async => (await getAccessToken()) != null;

  // ── Headers ───────────────────────────────────────────────
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getAccessToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ── HTTP methods ──────────────────────────────────────────
  Future<Map<String, dynamic>> get(String path) async {
    var res = await _client
        .get(Uri.parse('$kBaseUrl$path'), headers: await _headers())
        .timeout(_kTimeout);
    if (res.statusCode == 401) {
      await _refresh();
      res = await _client
          .get(Uri.parse('$kBaseUrl$path'), headers: await _headers())
          .timeout(_kTimeout);
    }
    return _parse(res);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$kBaseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body),
        )
        .timeout(_kTimeout);
    return _parse(res);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    var res = await _client
        .patch(
          Uri.parse('$kBaseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(_kTimeout);
    if (res.statusCode == 401) {
      await _refresh();
      res = await _client
          .patch(Uri.parse('$kBaseUrl$path'), headers: await _headers(), body: jsonEncode(body))
          .timeout(_kTimeout);
    }
    return _parse(res);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    var res = await _client
        .put(
          Uri.parse('$kBaseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(_kTimeout);
    if (res.statusCode == 401) {
      await _refresh();
      res = await _client
          .put(Uri.parse('$kBaseUrl$path'), headers: await _headers(), body: jsonEncode(body))
          .timeout(_kTimeout);
    }
    return _parse(res);
  }

  Future<void> delete(String path) async {
    var res = await _client
        .delete(Uri.parse('$kBaseUrl$path'), headers: await _headers())
        .timeout(_kTimeout);
    if (res.statusCode == 401) {
      await _refresh();
      res = await _client
          .delete(Uri.parse('$kBaseUrl$path'), headers: await _headers())
          .timeout(_kTimeout);
    }
    if (res.statusCode >= 400) _throwError(res);
  }

  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    final token = await getAccessToken();
    final req = http.MultipartRequest('POST', Uri.parse('$kBaseUrl/users/me/avatar'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: _mimeTypeFromPath(filePath),
    ));
    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);
    return _parse(res);
  }

  Future<Map<String, dynamic>> uploadPhoto(String filePath, {String? placeId}) async {
    final token = await getAccessToken();
    final req = http.MultipartRequest('POST', Uri.parse('$kBaseUrl/photos/upload'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: _mimeTypeFromPath(filePath),
    ));
    if (placeId != null) req.fields['place_id'] = placeId;
    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);
    return _parse(res);
  }

  // ── Token refresh ─────────────────────────────────────────
  Future<void> _refresh() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return;
    try {
      final res = await _client
          .post(
            Uri.parse('$kBaseUrl/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(_kTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await saveTokens(data['access_token'], data['refresh_token']);
      } else {
        await clearTokens();
      }
    } catch (_) {}
  }

  // ── Response parsing ──────────────────────────────────────
  Map<String, dynamic> _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return _throwError(res);
  }

  MediaType _mimeTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    const map = {'png': 'png', 'webp': 'webp'};
    return MediaType('image', map[ext] ?? 'jpeg');
  }

  Never _throwError(http.Response res) {
    String msg = 'เกิดข้อผิดพลาด (${res.statusCode})';
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final detail = body['detail'];
      if (detail is String) {
        msg = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // Pydantic validation error → ดึง msg จาก error แรก
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          msg = (first['msg'] as String).replaceFirst('Value error, ', '');
        }
      }
    } catch (_) {}
    throw ApiException(res.statusCode, msg);
  }
}
