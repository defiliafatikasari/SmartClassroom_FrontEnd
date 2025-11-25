import 'dart:convert';
import 'api.dart';
import '../models/user.dart';

class AuthService {
  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final response = await Api.post('/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'role': role,
    });

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await Api.setToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await Api.post('/login', body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await Api.setToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    try {
      await Api.post('/logout');
    } catch (e) {
      // Continue with local logout even if API call fails
    }
    await Api.removeToken();
  }

  Future<User?> getProfile() async {
    try {
      final response = await Api.get('/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
    } catch (e) {
      // Token might be invalid
    }
    return null;
  }

  Future<User> updateProfile(String name, String email) async {
    final response = await Api.put('/profile', body: {
      'name': name,
      'email': email,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update profile');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await Api.getToken();
    return token != null;
  }
}