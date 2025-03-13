import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omus/services/login/login_services.dart';
import 'package:omus/services/login/models/login_request.dart';

@immutable
class AuthenticationState extends Equatable {
  final bool isAuthenticated;
  const AuthenticationState({
    required this.isAuthenticated,
  });

  @override
  List<Object?> get props => [isAuthenticated];
}

class AuthenticationBloc extends Cubit<AuthenticationState> {
  AuthenticationBloc()
      : super(
          const AuthenticationState(isAuthenticated: false),
        );

  Future<void> confirmLogin(LoginRequest body) async {
    await AuthenticationService.authenticate(body);

    emit(const AuthenticationState(isAuthenticated: true));
  }

  Future<void> logout() async {
    emit(const AuthenticationState(isAuthenticated: false));
  }
}
