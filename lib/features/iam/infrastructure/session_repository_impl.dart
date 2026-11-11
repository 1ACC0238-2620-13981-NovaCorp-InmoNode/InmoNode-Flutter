import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';
import 'package:inmonode/features/iam/infrastructure/local/stored_session.dart';

/// Keeps the session in the Android Keystore or, on Web, encrypted with WebCrypto.
///
/// The session is also cached in memory, because every protected request reads it.
class SessionRepositoryImpl implements SessionRepository {
  static const String _key = 'inmonode.session';

  final FlutterSecureStorage storage;
  Session? _cached;
  bool _loaded = false;

  SessionRepositoryImpl({required this.storage});

  @override
  Future<Session?> load() async {
    if (!_loaded) {
      _cached = await _read();
      _loaded = true;
    }
    return _cached;
  }

  @override
  Future<void> save(Session session) async {
    _cached = session;
    _loaded = true;
    await storage.write(key: _key, value: jsonEncode(StoredSession.toJson(session)));
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await storage.delete(key: _key);
  }

  Future<Session?> _read() async {
    try {
      final value = await storage.read(key: _key);
      if (value == null) return null;
      return StoredSession.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      // Unreadable storage or a value in an older format: start signed out.
      await storage.delete(key: _key);
      return null;
    }
  }
}
