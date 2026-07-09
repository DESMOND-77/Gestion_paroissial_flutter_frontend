import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../blocs/auth/auth_bloc.dart';

/// Netflix-style intro: plays the brand animation full-screen on cold start,
/// then routes to /dashboard or /login once both the animation has finished
/// and the auth check has resolved.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  StreamSubscription<AuthState>? _authSubscription;

  bool _animationDone = false;
  String? _targetRoute;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    loadAnimation();

    final authBloc = context.read<AuthBloc>();
    _resolveTarget(authBloc.state);
    _authSubscription = authBloc.stream.listen(_resolveTarget);
  }

  Future<Timer> loadAnimation() async {
    return Timer(const Duration(milliseconds: 5300), () {
      _animationDone = true;
      _tryNavigate();
    });
  }

  void _resolveTarget(AuthState state) {
    if (state is AuthAuthenticated || state is AuthLoginSuccess) {
      _targetRoute = '/dashboard';
      _tryNavigate();
    } else if (state is AuthUnauthenticated || state is AuthError) {
      _targetRoute = '/login';
      _tryNavigate();
    }
  }

  void _tryNavigate() {
    if (!mounted || !_animationDone || _targetRoute == null) return;
    context.go(_targetRoute!);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          'assets/lotties/gestparr.json',
          width: 260,
          height: 260,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// return Timer(const Duration(seconds: 4), onLoaded);
