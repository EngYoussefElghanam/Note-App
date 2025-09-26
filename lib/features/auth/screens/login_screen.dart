import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:notes_taker/features/auth/cubit/auth_cubit.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';
import 'package:notes_taker/core/cubit/theme_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight =
        context.watch<ThemeCubit>().state is ThemeLoaded &&
        (context.watch<ThemeCubit>().state as ThemeLoaded).isLight;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ---------- TOP BACKGROUND ----------
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    isLight
                        ? 'assets/images/background.png'
                        : 'assets/images/background_dark.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 30,
                    width: 80,
                    height: 200,
                    child: FadeInUp(
                      duration: const Duration(seconds: 1),
                      child: GestureDetector(
                        onTap: () => context.read<ThemeCubit>().toggleTheme(),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              opacity: isLight ? 1 : 0.4,
                              image: AssetImage('assets/images/light-1.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 140,
                    width: 80,
                    height: 150,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: GestureDetector(
                        onTap: () => context.read<ThemeCubit>().toggleTheme(),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              opacity: isLight ? 1 : 0.4,
                              image: AssetImage('assets/images/light-2.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1600),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 60),
                        child: Center(
                          child: Text(
                            "Login",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- INPUTS & BUTTON ----------
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          // Email field
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: emailController,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                hintStyle: theme.inputDecorationTheme.hintStyle,
                              ),
                            ),
                          ),
                          // Password field
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: theme.inputDecorationTheme.hintStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ---------- LOGIN BUTTON ----------
                  BlocConsumer<AuthCubit, AuthState>(
                    listenWhen: (previous, current) =>
                        previous is! AuthSuccess && current is AuthSuccess ||
                        previous is! AuthFailure && current is AuthFailure,
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (Route<dynamic> route) => false,
                        );
                      } else if (state is AuthFailure) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const CircularProgressIndicator();
                      }
                      return Column(
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 1900),
                            child: GestureDetector(
                              onTap: () => context.read<AuthCubit>().login(
                                emailController.text,
                                passwordController.text,
                              ),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // ---------- GOOGLE SIGN IN BUTTON ----------
                          FadeInUp(
                            duration: const Duration(milliseconds: 2000),
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<AuthCubit>().googleLogin();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 20,
                                ),
                                side: BorderSide(
                                  color: theme.dividerColor,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: theme.colorScheme.surface,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google.png',
                                    height: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Sign in with Google",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // ---------- FORGOT PASSWORD ----------
                  GestureDetector(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.forgetPassword),
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 2000),
                      child: Text(
                        "Forgot Password?",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- REGISTER LINK ----------
                  FadeInUp(
                    duration: const Duration(milliseconds: 2200),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.register,
                        );
                      },
                      child: Text(
                        "Don’t have an account? Register",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
