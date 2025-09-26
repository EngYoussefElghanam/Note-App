import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_taker/core/services/img_service.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';
import 'package:notes_taker/models/user_info.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthServicesImpl _authService;
  AuthCubit(this._authService) : super(AuthInitial());

  // Register with email & password
  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      final uid = await _authService.register(email, password, name);
      emit(AuthSuccess(uid));
    } catch (e) {
      emit(AuthFailure("Error happened: ${e.toString()}"));
    }
  }

  // Login with email & password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final userId = await _authService.login(email, password);
      emit(AuthSuccess(userId));
    } catch (e) {
      emit(AuthFailure("Failed to login: ${e.toString()}"));
    }
  }

  // Login using Google
  Future<void> googleLogin() async {
    emit(AuthLoading());
    try {
      final userId = await _authService.googleLogin();
      emit(AuthSuccess(userId));
    } catch (e) {
      emit(AuthFailure("Failed to login with Google: ${e.toString()}"));
    }
  }

  // Forget password
  Future<void> forgetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authService.forgetPassword(email);
      emit(AuthPasswordResetSuccess("Password reset email sent to $email"));
    } catch (e) {
      emit(AuthFailure("Failed to reset password: ${e.toString()}"));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure("Failed to logout: ${e.toString()}"));
    }
  }

  Future<void> updateUserData({String? name, XFile? pickedFile}) async {
    emit(AuthLoading());
    try {
      final currentData = await _authService.getUserData();

      String imgUrl = currentData?.imgUrl ?? "";

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        if (!await file.exists()) {
          throw Exception("Picked file does not exist: ${file.path}");
        }

        // ✅ Upload to Cloudinary instead of Firebase Storage
        imgUrl = await uploadToCloudinary(pickedFile);
      }

      final updatedName = name ?? currentData?.name ?? "No Name";

      await _authService.updateUserData(name: updatedName, imgUrl: imgUrl);

      emit(AuthSuccess(_authService.currentUser()!.uid));
    } catch (e, st) {
      print("❌ updateUserData failed: $e");
      print("Stacktrace: $st");
      emit(AuthFailure("Failed to update user data: ${e.toString()}"));
    }
  }

  Future<UserData?> getUserData({bool refreshImage = false}) async {
    try {
      final user = await _authService.getUserData();
      if (user?.imgUrl != null) {
        if (refreshImage) {
          await ImageCacheService().saveFromUrl(user!.imgUrl!);
        }
        user?.cachedImage = await ImageCacheService().loadCached();
      }
      return user;
    } catch (e) {
      emit(AuthFailure("Failed to fetch user data: ${e.toString()}"));
      return null;
    }
  }

  Future<void> updateUserProfile(XFile picked, String name) async {
    final saved = await ImageCacheService().saveFromXFile(picked);
    await updateUserData(name: name, pickedFile: picked);
    emit(AuthSuccess(saved!.path));
  }
}
