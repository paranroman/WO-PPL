import 'dart:io';
import 'package:eventure/utils/toast_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../api/database_service.dart';
import '../api/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = false;
  UserModel? _currentUserData;

  bool get isLoading => _isLoading;

  UserModel? get currentUserData => _currentUserData;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> currentUser() async {
    return _authService.currentUser!.uid;
  }

  Future<bool> isSignedIn() async {
    return _authService.currentUser != null;
  }

  Future<UserModel?> getUserData() async {
    try {
      final uid = await currentUser();
      final user = await _databaseService.getUserData(uid);

      if (user != null) {
        _currentUserData = user;
        notifyListeners();
      }

      return user;
    } catch (_) {
      ToastHelper.showShortToast("Gagal memuat data pengguna");
      return null;
    }
  }

  Future<bool> changeUserData({
    String? name,
    String? email,
    String? phone,
    File? newKtm,
    File? newProfilePicture,
  }) async {
    _setLoading(true);

    try {
      final uid = await currentUser();
      final updateData = <String, dynamic>{};

      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        updateData['email'] = email.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
      }

      if (newKtm != null) {
        final ktmUrl = await _storageService.uploadKtmImage(newKtm, uid);
        if (ktmUrl != null) {
          updateData['ktm'] = ktmUrl;
        }
      }

      if (newProfilePicture != null) {
        final profileUrl = await _storageService.uploadProfilePicture(
          newProfilePicture,
          uid,
        );
        if (profileUrl != null) {
          updateData['profilePicture'] = profileUrl;
        }
      }

      if (updateData.isNotEmpty) {
        await FirebaseDatabase.instance.ref("users/$uid").update(updateData);
      }

      if (_currentUserData != null) {
        _currentUserData = _currentUserData!.copyWith(
          name: updateData['name'],
          email: updateData['email'],
          phone: updateData['phone'],
          ktm: updateData['ktm'],
          profilePicture: updateData['profilePicture'],
        );
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      ToastHelper.showShortToast("Gagal mengubah data");
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required File file,
  }) async {
    _setLoading(true);

    try {
      final uid = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (uid == null) {
        _setLoading(false);
        return false;
      }

      final ktmUrl = await _storageService.uploadKtmImage(file, uid);

      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: '',
        ktm: ktmUrl ?? '',
        profilePicture: '',
      );

      await _databaseService.saveUserData(user);

      _currentUserData = user;
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await getUserData();
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUserData = null;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }
}
