import 'package:firebase_auth/firebase_auth.dart';
import '../utils/toast_helper.dart';

/// A service class that wraps Firebase Authentication logic.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Signs in a user and shows toast notifications for common errors.
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ToastHelper.showShortToast('Email tidak terdaftar.');
      } else if (e.code == 'wrong-password') {
        ToastHelper.showShortToast('Password salah.');
      } else {
        ToastHelper.showShortToast('Terjadi kesalahan. Coba lagi.');
      }
      // Rethrow to allow the UI/Provider to handle the state (e.g., stop loading).
      rethrow;
    }
  }

  /// Registers a new user and shows a toast for 'email-already-in-use'.
  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ToastHelper.showShortToast('Email sudah digunakan oleh akun lain.');
      } else {
        ToastHelper.showShortToast('Gagal mendaftar. Coba lagi.');
      }
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      ToastHelper.showShortToast('Gagal keluar. Coba lagi.');
    }
  }

  /// Changes password and shows a toast for 'wrong-password'.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user found to change password.');
      }
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      ToastHelper.showShortToast(
        'Password berhasil diubah. Silakan masuk kembali',
      );
      await signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        ToastHelper.showShortToast('Password saat ini salah.');
      } else {
        ToastHelper.showShortToast('Gagal mengubah password.');
      }
      rethrow;
    }
  }

  /// Sends a password reset email and handles 'user-not-found'.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ToastHelper.showShortToast('Email reset password telah dikirim.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ToastHelper.showShortToast('Email tidak terdaftar.');
      } else {
        ToastHelper.showShortToast('Gagal mengirim email reset.');
      }
      rethrow;
    }
  }
}
