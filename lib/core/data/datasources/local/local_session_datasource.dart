import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/user_model.dart';
import '../interfaces/i_session_datasource.dart';

class LocalSessionDataSource implements ISessionDataSource {
  static const String _fileName = 'session.json';
  UserModel? _currentUser;
  String? _currentRole;

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        final map = json.decode(content);
        if (map['user'] != null) {
          _currentUser = UserModel.fromMap(map['user']);
          _currentRole = map['role'];
        }
      }
    } catch (e) {
      print('Error reading session: $e');
    }
    return _currentUser;
  }

  @override
  Future<String?> getCurrentRole() async {
    if (_currentRole != null) return _currentRole;
    await getCurrentUser(); // Ensure loaded
    return _currentRole;
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    _currentUser = user;
    _currentRole = user.currentRole;
    await _persistSession();
  }

  @override
  Future<void> saveCurrentRole(String role) async {
    _currentRole = role;
    if (_currentUser != null) {
      // Update user model role as well if needed, or just session role
      // For now, just persist
      await _persistSession();
    }
  }

  Future<void> _persistSession() async {
    try {
      final file = await _file;
      final map = {'user': _currentUser?.toMap(), 'role': _currentRole};
      await file.writeAsString(json.encode(map));
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    _currentUser = null;
    _currentRole = null;
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return (await getCurrentUser()) != null;
  }
}
