import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'registration.dart';
import 'otp_verification.dart';
import 'home_banking.dart';

class LoginBankingScreen extends StatefulWidget {
  const LoginBankingScreen({super.key});

  @override
  State<LoginBankingScreen> createState() => _LoginBankingScreenState();
}

class _LoginBankingScreenState extends State<LoginBankingScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _accountController;
  late final TextEditingController _mobileController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;

  bool _isLoading = false;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    _accountController = TextEditingController();
    _mobileController = TextEditingController();
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
    _accountController.dispose();
    _mobileController.dispose();
    super.dispose();
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _validateInput() {
    if (_accountController.text.isEmpty) {
      _showErrorSnackBar('Please enter your account number');
      return false;
    }

    if (_accountController.text.length < 8) {
      _showErrorSnackBar('Please enter a valid account number');
      return false;
    }

    if (_mobileController.text.isEmpty) {
      _showErrorSnackBar('Please enter your mobile number');
      return false;
    }

    if (_mobileController.text.length < 10) {
      _showErrorSnackBar('Please enter a valid mobile number');
      return false;
    }

    return true;
  }

  // Check if current session is already verified
  Future<bool> _isSessionVerified(
      String mobileNumber, String accountNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final account = accountNumber;
      final sessionKey = '${mobile}_${account}_session'.toLowerCase();

      final timestamp = prefs.getInt('verified_session_$sessionKey');
      if (timestamp == null) return false;

      // Check if session is still valid (30 days)
      final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(sessionTime).inDays;

      return difference <= 30;
    } catch (e) {
      debugPrint('Error checking session verification: $e');
      return false;
    }
  }

  void _proceedToLogin() async {
    if (!_validateInput()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call for account validation (in real app, validate with backend)
      await Future.delayed(const Duration(seconds: 1));

      // Check if session is already verified
      final isVerified = await _isSessionVerified(
        _mobileController.text,
        _accountController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (isVerified) {
          // Skip OTP and go directly to home
          _showSuccessSnackBar('Welcome back! Logged in successfully.');
          _navigateDirectlyToHome();
        } else {
          // Show OTP verification screen
          _navigateToOTP();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Login failed. Please try again.');
      }
    }
  }

  void _navigateDirectlyToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const HomeScreen2(),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(0.0, 1.0);
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _navigateToOTP() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => OTPVerificationScreen(
          mobileNumber: _formatMobileNumber(_mobileController.text),
          accountNumber: _accountController.text,
        ),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(1.0, 0.0);
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  String _formatMobileNumber(String mobile) {
    // Format mobile number for display (e.g., +94 77 123 4567)
    if (mobile.startsWith('0')) {
      mobile = '+94 ${mobile.substring(1)}';
    } else if (!mobile.startsWith('+94')) {
      mobile = '+94 $mobile';
    }

    // Add spacing for better readability
    if (mobile.length >= 12) {
      return '${mobile.substring(0, 3)} ${mobile.substring(3, 5)} ${mobile.substring(5, 8)} ${mobile.substring(8)}';
    }
    return mobile;
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const RegistrationScreen(),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(1.0, 0.0);
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
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
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 40),
                    _buildAccountNumberField(),
                    const SizedBox(height: 16),
                    _buildMobileNumberField(),
                    const SizedBox(height: 30),
                    _buildContinueButton(),
                    const SizedBox(height: 20),
                    _buildSessionInfo(),
                    const SizedBox(height: 40),
                    _buildRegistrationLink(),
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

  Widget _buildSubtitle() {
    return Text(
      'Secure Banking at Your Fingertips',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAccountNumberField() {
    return _CustomTextField(
      controller: _accountController,
      label: 'Account Number',
      hint: '12345678901234',
      icon: Icons.account_balance_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
      ],
    );
  }

  Widget _buildMobileNumberField() {
    return _CustomTextField(
      controller: _mobileController,
      label: 'Mobile Number',
      hint: '0771234567',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
        _MobileNumberFormatter(),
      ],
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: _primaryColor.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Secure login: OTP required only once every 30 days on this device',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
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
        onPressed: _isLoading ? null : _proceedToLogin,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Continue',
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
              ),
      ),
    );
  }

  Widget _buildRegistrationLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: _navigateToRegistration,
          child: const Text(
            'Register',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom TextField widget for reusability
class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.isPassword = false,
    this.obscureText,
    this.onToggleVisibility,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool isPassword;
  final bool? obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

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
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryColor, size: 22),
          suffixIcon: isPassword ? _buildPasswordToggle() : null,
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
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

// Mobile number formatter for better UX
class _MobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 10 digits
    if (text.length > 10) {
      return oldValue;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
