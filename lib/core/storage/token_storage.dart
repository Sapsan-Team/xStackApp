import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStorage(storage);
});

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';

  // The keyring is shared by every process of this user session, so re-reading
  // it per request would let a parallel instance silently switch our identity
  // to whoever logged in last. Tokens are pinned in memory on write/first read
  // instead, and requests keep using the pinned values.
  String? _cachedToken;
  String? _cachedRefreshToken;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getToken() async {
    final cached = _cachedToken;
    if (cached != null && cached.isNotEmpty) return cached;
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      _cachedToken = token;
    }
    return token;
  }

  Future<String?> getRefreshToken() async {
    final cached = _cachedRefreshToken;
    if (cached != null && cached.isNotEmpty) return cached;
    final token = await _storage.read(key: _refreshTokenKey);
    if (token != null && token.isNotEmpty) {
      _cachedRefreshToken = token;
    }
    return token;
  }

  Future<void> deleteTokens() async {
    _cachedToken = null;
    _cachedRefreshToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
