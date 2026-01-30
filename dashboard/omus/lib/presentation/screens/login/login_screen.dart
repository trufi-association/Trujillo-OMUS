import 'package:flutter/material.dart';
import 'package:omus/authentication/authentication_bloc.dart';
import 'package:omus/presentation/widgets/common/general_app_bar.dart';
import 'package:omus/services/login/models/login_request.dart';
import 'package:omus/widgets/async_handler.dart';
import 'package:omus/widgets/components/helpers/form_request_container.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';
import 'package:omus/widgets/custom_button.dart';
import 'package:provider/provider.dart';

/// Login screen for admin authentication.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const GeneralAppBar(title: ''),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          _buildGradientOverlay(),
          _buildLoginForm(context),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/background.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(153, 17, 81, 134),
              Color.fromARGB(125, 0, 0, 0),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 24,
            right: 24,
          ),
          child: Column(
            children: [
              Container(
                height: 490,
                width: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: FormRequestContainer<LoginRequest>(
                  create: () => LoginRequest.fromScratch(),
                  builder: (params) {
                    final model = params.model;
                    return AsyncHelper(
                      builder: (asyncState) => Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0,
                          top: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(
                              child: Text(
                                'Admin panel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 99, 99, 98),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FormRequestField(
                              update: model.update,
                              label: 'username',
                              field: model.email,
                              enabled: !asyncState.loadingStatus.isLoading,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                            ),
                            const SizedBox(height: 16),
                            FormRequestField(
                              update: model.update,
                              field: model.password,
                              autofillHints: const [AutofillHints.password],
                              enabled: !asyncState.loadingStatus.isLoading,
                              obscureText: true,
                              label: 'password',
                            ),
                            const SizedBox(height: 16),
                            _AuthErrorDisplay(
                              errorCode: asyncState.loadingStatus.errorCode,
                            ),
                            const SizedBox(height: 10),
                            CustomButton(
                              height: 70,
                              width: null,
                              buttonShape: ButtonShape.extraRounded,
                              loading: asyncState.loadingStatus.isLoading,
                              onTap: asyncState.loadingStatus.isLoading
                                  ? null
                                  : () {
                                      if (!params.isFormCompleted()) {
                                        return;
                                      }
                                      asyncState.runAsync.call(() async {
                                        await context
                                            .read<AuthenticationBloc>()
                                            .confirmLogin(model);
                                      });
                                    },
                              label: 'Login',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to display authentication errors.
class _AuthErrorDisplay extends StatelessWidget {
  const _AuthErrorDisplay({required this.errorCode});

  final String? errorCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (errorCode != null)
          Text(
            errorCode.toString(),
            style: TextStyle(color: theme.colorScheme.error),
          )
        else
          const SizedBox(height: 24),
      ],
    );
  }
}
