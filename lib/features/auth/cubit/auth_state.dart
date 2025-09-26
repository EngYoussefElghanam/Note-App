part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final String uid;
  AuthSuccess(this.uid);
}

final class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

final class AuthPasswordResetSuccess extends AuthState {
  final String message;
  AuthPasswordResetSuccess(this.message);
}
