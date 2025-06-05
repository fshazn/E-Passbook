import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;

  bool _obscureText = true;
  bool _isLoading = false;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 1200);
  static const Duration _transitionDuration = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _validateInput() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter both username and password');
      return false;
    }
    return true;
  }

  void _login() {
    if (!_validateInput()) return;

    setState(() => _isLoading = true);

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      _createSlideTransition(
        child: const HomeScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    );
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      _createSlideTransition(
        child: const RegistrationScreen(),
        begin: const Offset(1.0, 0.0),
      ),
    );
  }

  PageRouteBuilder _createSlideTransition({
    required Widget child,
    required Offset begin,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) {
        final tween = Tween(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: _transitionDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: FadeTransition(
          opacity: _fadeInAnimation,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLogo(),
                    const SizedBox(height: 24),
                    _buildAppTitle(),
                    const SizedBox(height: 40),
                    _buildUsernameField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    _buildForgotPasswordButton(),
                    const SizedBox(height: 30),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildSignUpOption(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _containerColor.withOpacity(0.2),
          border: Border.all(color: _primaryColor, width: 2),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: _primaryColor,
          size: 50,
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return const Text(
      'E-Passbook',
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontFamily: 'Righteous',
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildUsernameField() {
    return _CustomTextField(
      controller: _usernameController,
      label: 'Username',
      icon: Icons.person_outline,
    );
  }

  Widget _buildPasswordField() {
    return _CustomTextField(
      controller: _passwordController,
      label: 'Password',
      icon: Icons.lock_outline,
      isPassword: true,
      obscureText: _obscureText,
      onToggleVisibility: _togglePasswordVisibility,
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Handle forgot password
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(50, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isLoading ? null : _login,
        child:
            _isLoading ? _buildLoadingIndicator() : _buildLoginButtonContent(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    );
  }

  Widget _buildLoginButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Log In',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward, size: 16),
        ),
      ],
    );
  }

  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        GestureDetector(
          onTap: _navigateToRegistration,
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom TextField Widget for better reusability and performance
class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.obscureText,
    this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool? obscureText;
  final VoidCallback? onToggleVisibility;

  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? (obscureText ?? false) : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryColor, size: 22),
          suffixIcon: isPassword ? _buildPasswordToggle() : null,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          floatingLabelStyle:
              const TextStyle(color: _primaryColor, fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordToggle() {
    return IconButton(
      icon: Icon(
        (obscureText ?? false) ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey[400],
        size: 22,
      ),
      onPressed: onToggleVisibility,
    );
  }
}
