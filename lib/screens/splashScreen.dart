import 'package:e_pass_app/screens/login_banking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _progressTimer;

  double _loadingProgress = 0.0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);

  // Animation constants
  static const Duration _animationDuration = Duration(milliseconds: 2000);
  static const Duration _navigationDelay = Duration(milliseconds: 500);
  static const Duration _progressInterval = Duration(milliseconds: 50);

  // Animation intervals
  static const double _logoStartTime = 0.0;
  static const double _logoEndTime = 0.6;
  static const double _textStartTime = 0.3;
  static const double _textEndTime = 0.8;
  static const double _fadeStartTime = 0.5;
  static const double _fadeEndTime = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startLoadingProgress();
  }

  void _setupAnimations() {
    _controller =
        AnimationController(vsync: this, duration: _animationDuration);
    _controller.forward();
  }

  void _startLoadingProgress() {
    _progressTimer = Timer.periodic(_progressInterval, (timer) {
      if (mounted) {
        setState(() {
          if (_loadingProgress < 1.0) {
            _loadingProgress += 0.02;
          } else {
            timer.cancel();
            _navigateToLogin();
          }
        });
      }
    });
  }

  void _navigateToLogin() {
    Future.delayed(_navigationDelay, () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => const LoginBankingScreen(),
            //const LoginScreen(),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: Stack(
          children: [
            _buildBackgroundElements(),
            _buildMainContent(),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: _BackgroundCircle(
            size: 250,
            opacity: 0.03,
            color: _primaryColor,
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: _BackgroundCircle(
            size: 200,
            opacity: 0.02,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedLogo(),
          const SizedBox(height: 40),
          _buildAnimatedTitle(),
          const SizedBox(height: 12),
          _buildAnimatedTagline(),
          const SizedBox(height: 60),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final logoInterval = Interval(
          _logoStartTime,
          _logoEndTime,
          curve: Curves.elasticOut,
        );
        final rotateInterval = Interval(
          _logoStartTime,
          _logoEndTime * 0.5,
          curve: Curves.easeOut,
        );

        final scale = logoInterval.transform(_controller.value);
        final rotation = rotateInterval.transform(_controller.value);

        return Transform.rotate(
          angle: (1 - rotation) * -0.5 * 3.14,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: const _LogoContainer(),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final textInterval = Interval(
          _textStartTime,
          _textEndTime,
          curve: Curves.easeOutCubic,
        );

        final progress = textInterval.transform(_controller.value);
        final scale = 0.5 + (progress * 0.5);
        final offset = Offset(0.0, (1 - progress) * 0.5);

        return SlideTransition(
          position: AlwaysStoppedAnimation(offset),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: const _AppTitle(),
    );
  }

  Widget _buildAnimatedTagline() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final fadeInterval = Interval(
          _fadeStartTime,
          _fadeEndTime,
          curve: Curves.easeOut,
        );

        final opacity = fadeInterval.transform(_controller.value);

        return Opacity(opacity: opacity, child: child);
      },
      child: const _AppTagline(),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final fadeInterval = Interval(
          _fadeStartTime,
          _fadeEndTime,
          curve: Curves.easeOut,
        );

        final opacity = fadeInterval.transform(_controller.value);

        return Opacity(
          opacity: opacity,
          child: _LoadingIndicator(progress: _loadingProgress),
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final fadeInterval = Interval(
            _fadeStartTime,
            _fadeEndTime,
            curve: Curves.easeOut,
          );

          final opacity = fadeInterval.transform(_controller.value);

          return Opacity(opacity: opacity, child: child);
        },
        child: const _VersionInfo(),
      ),
    );
  }
}

// Reusable components
class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({
    required this.size,
    required this.opacity,
    required this.color,
  });

  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

class _LogoContainer extends StatelessWidget {
  const _LogoContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.2),
        border: Border.all(color: const Color(0xFF00FFEB), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFEB).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.account_balance_wallet,
        color: Color(0xFF00FFEB),
        size: 60,
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'E-Passbook',
      style: TextStyle(
        color: Colors.white,
        fontSize: 40,
        fontFamily: 'Righteous',
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    );
  }
}

class _AppTagline extends StatelessWidget {
  const _AppTagline();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Your Digital Banking Solution',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF00FFEB)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionInfo extends StatelessWidget {
  const _VersionInfo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Version 1.0.4',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}
