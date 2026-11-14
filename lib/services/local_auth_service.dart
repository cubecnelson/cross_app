import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/ontherack_constants.dart';
import '../models/app_session.dart';
import 'catalog_service.dart';
import 'password_hasher.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Local username/password auth stored alongside the Hive (or memory) catalog.
/// Used for writes in v1 so the app runs without a new cloud schema.
class LocalAuthService {
  LocalAuthService(this._catalog, {this.sessionBoxName = 'otr_session'});

  final CatalogService _catalog;
  final String sessionBoxName;
  final Uuid _uuid = const Uuid();
  AppSession? _session;
  Box? _sessionBox;

  AppSession? get session => _session;

  Future<void> initialize() async {
    if (_catalog.backend is MemoryCatalogBackend) {
      return;
    }
    _sessionBox = await Hive.openBox(sessionBoxName);
    final raw = _sessionBox!.get('current');
    if (raw is Map) {
      _session = AppSession.fromMap(raw);
    }
  }

  Future<AppSession> signIn({
    required String username,
    required String password,
  }) async {
    final user = _catalog.backend.getUserByUsername(username.trim());
    if (user == null) {
      throw AuthException('Incorrect username or password');
    }
    final salt = user['salt'] as String? ?? PasswordHasher.seedSalt;
    final hash = user['passwordHash'] as String? ?? '';
    if (!PasswordHasher.verify(password, salt, hash)) {
      throw AuthException('Incorrect username or password');
    }
    final session = AppSession(
      userId: user['id'] as String,
      username: user['username'] as String,
      source: 'local',
    );
    await _persist(session);
    return session;
  }

  Future<AppSession> register({
    required String username,
    required String password,
  }) async {
    final name = username.trim();
    if (!OnTheRackConstants.usernamePattern.hasMatch(name)) {
      throw AuthException(
        'Username must be 3–24 letters, numbers, or underscores',
      );
    }
    if (password.length < OnTheRackConstants.minPasswordLength) {
      throw AuthException('Password must be at least 8 characters');
    }
    if (_catalog.backend.getUserByUsername(name) != null) {
      throw AuthException('That username is already taken');
    }
    final id = _uuid.v4();
    final salt = PasswordHasher.randomSalt();
    await _catalog.backend.putUser(id, {
      'id': id,
      'username': name,
      'passwordHash': PasswordHasher.hash(password, salt),
      'salt': salt,
      'isSample': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    final session = AppSession(userId: id, username: name, source: 'local');
    await _persist(session);
    return session;
  }

  Future<void> signOut() async {
    _session = null;
    await _sessionBox?.delete('current');
  }

  Future<void> _persist(AppSession session) async {
    _session = session;
    await _sessionBox?.put('current', session.toMap());
  }
}
