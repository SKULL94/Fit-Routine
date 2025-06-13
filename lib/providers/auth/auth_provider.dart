import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/user/user.dart';

part 'auth_provider.g.dart';

const _userKey = 'user_data';
const _credentialsKey = 'user_credentials';
const _uuid = Uuid();

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() {
    _loadUser();
    return null;
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      state = User.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = user;
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _credentialsKey,
        jsonEncode({
          'email': email,
          'password': password,
        }));
  }

  Future<Map<String, String>?> _getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_credentialsKey);
    if (credentialsJson != null) {
      final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
      return {
        'email': credentials['email'] as String,
        'password': credentials['password'] as String,
      };
    }
    return null;
  }

  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 3));

    final credentials = await _getCredentials();

    // Check if credentials exist and match
    if (credentials != null &&
        credentials['email'] == email &&
        credentials['password'] == password) {
      final userJson = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString(_userKey));

      if (userJson != null) {
        state = User.fromJson(jsonDecode(userJson));
        return true;
      }
    }

    // if no stored credentials or they don't match, check default test account
    if (email == "test@test.com" && password == "password") {
      final user = User(
        id: _uuid.v4(),
        name: 'Test User',
        email: email,
        isAuthenticated: true,
      );
      await _saveUser(user);
      await _saveCredentials(email, password);
      return true;
    }

    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 3));

    if (email.isNotEmpty && password.length >= 6) {
      final user = User(
        id: _uuid.v4(),
        name: name,
        email: email,
        isAuthenticated: true,
      );
      await _saveUser(user);
      await _saveCredentials(email, password);
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    state = null;
  }

  Future<void> updateProfile({String? name, String? bio}) async {
    if (state == null) return;

    final updatedUser = state!.copyWith(
      name: name ?? state!.name,
      bio: bio ?? state!.bio,
    );
    await _saveUser(updatedUser);
  }
}
