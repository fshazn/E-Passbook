// login_page.dart - COMPLETE UPDATED FILE WITH SECURITY FIX
import 'dart:async';

import 'package:e_pass_app/screens/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'registration_screen.dart';
import 'forgot_code_screen.dart';
import 'accounts.dart';
import 'biometrics_setup.dart';

class LoginBankingScreen extends StatefulWidget {
  const LoginBankingScreen({super.key});

  @override
  State<LoginBankingScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginBankingScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _accountController;
  late final TextEditingController _accessCodeController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;
  late final LocalAuthentication _localAuth;

  bool _isLoading = false;
  bool _showBiometricOption = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  String? _actualAccountNumber; // NEW: Store actual account number for security

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _initializeBiometrics();
    _checkSavedCredentials();
  }

  void _initializeControllers() {
    _accountController = TextEditingController();
    _accessCodeController = TextEditingController();
    _localAuth = LocalAuthentication();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _initializeBiometrics() async {
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics;
      if (_isBiometricAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
    } catch (e) {
      debugPrint('Error initializing biometrics: $e');
    }
  }

  // NEW: Method to mask account number for display
  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber; // Don't mask if too short
    }

    // Show first 2 and last 4 digits, mask the rest
    final firstPart = accountNumber.substring(0, 2);
    final lastPart = accountNumber.substring(accountNumber.length - 4);
    final maskedLength = accountNumber.length - 6;
    final masked = '*' * maskedLength;

    return '$firstPart$masked$lastPart';
  }

  // UPDATED: Check saved credentials with masking
  Future<void> _checkSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAccount = prefs.getString('saved_account_number');
      final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

      if (savedAccount != null && biometricEnabled) {
        setState(() {
          // Store the actual account number for biometric login but display masked version
          _actualAccountNumber = savedAccount;
          _accountController.text = _maskAccountNumber(savedAccount);
          _showBiometricOption = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking saved credentials: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accountController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  // Extract CIF from account number (last 7 digits)
  String _extractCIF(String accountNumber) {
    if (accountNumber.length >= 7) {
      return accountNumber.substring(accountNumber.length - 7);
    }
    return accountNumber; // Return full number if less than 7 digits
  }

  // UPDATED: Validate input using actual account number when available
  bool _validateInput() {
    final accountToValidate = _actualAccountNumber ?? _accountController.text;

    if (accountToValidate.isEmpty) {
      _showErrorSnackBar('Please enter your account number');
      return false;
    }

    if (accountToValidate.length < 8) {
      _showErrorSnackBar('Please enter a valid account number');
      return false;
    }

    if (_accessCodeController.text.isEmpty) {
      _showErrorSnackBar('Please enter your access code');
      return false;
    }

    if (_accessCodeController.text.length < 4) {
      _showErrorSnackBar('Please enter a valid access code');
      return false;
    }

    return true;
  }

  // UPDATED: Check if user is registered using actual account number
  Future<bool> _checkUserRegistration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountToValidate = _actualAccountNumber ?? _accountController.text;
      final cif = _extractCIF(accountToValidate);
      final registeredCIFs = prefs.getStringList('registered_cifs') ?? [];
      return registeredCIFs.contains(cif);
    } catch (e) {
      debugPrint('Error checking registration: $e');
      return false;
    }
  }

  // UPDATED: Validate credentials using actual account number
  Future<bool> _validateCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountToValidate = _actualAccountNumber ?? _accountController.text;
      final cif = _extractCIF(accountToValidate);
      final savedCode = prefs.getString('access_code_$cif');
      return savedCode == _accessCodeController.text;
    } catch (e) {
      debugPrint('Error validating credentials: $e');
      return false;
    }
  }

  void _proceedToLogin() async {
    if (!_validateInput()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if user is registered
      final isRegistered = await _checkUserRegistration();

      if (!isRegistered) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Account not registered. Please register first.');
        return;
      }

      // Validate credentials
      final isValidCredentials = await _validateCredentials();

      if (!isValidCredentials) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Invalid access code. Please try again.');
        return;
      }

      // Check if biometrics setup is complete
      final prefs = await SharedPreferences.getInstance();
      final accountToValidate = _actualAccountNumber ?? _accountController.text;
      final cif = _extractCIF(accountToValidate);
      final biometricsSetup = prefs.getBool('biometrics_setup_$cif') ?? false;

      setState(() => _isLoading = false);

      if (biometricsSetup) {
        // Go directly to accounts
        _navigateToAccounts();
      } else {
        // First time login - go to biometrics setup
        _navigateToBiometricsSetup();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Login failed. Please try again.');
    }
  }

  // UPDATED: Biometric authentication using actual account number
  Future<void> _authenticateWithBiometrics() async {
    setState(() => _isLoading = true);

    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (isAuthenticated) {
        // Use the actual account number for validation, not the masked one
        final accountToValidate =
            _actualAccountNumber ?? _accountController.text;

        // Check if user is registered using actual account number
        final prefs = await SharedPreferences.getInstance();
        final cif = _extractCIF(accountToValidate);
        final registeredCIFs = prefs.getStringList('registered_cifs') ?? [];

        if (!registeredCIFs.contains(cif)) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Account not registered. Please register first.');
          return;
        }

        _showSuccessSnackBar('Biometric authentication successful!');
        _navigateToAccounts();
      } else {
        _showErrorSnackBar('Biometric authentication was cancelled');
      }
    } catch (e) {
      _showErrorSnackBar('Biometric authentication failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAccounts() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const MainScreen(),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(0.0, 1.0);
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
      (route) => false,
    );
  }

  void _navigateToBiometricsSetup() {
    final accountToValidate = _actualAccountNumber ?? _accountController.text;
    final cif = _extractCIF(accountToValidate);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => BiometricsSetup(
          accountNumber: accountToValidate,
          cif: cif,
          accessCode: _accessCodeController.text,
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

  void _navigateToForgotCode() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const ForgotCodeScreen(),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(0.0, 1.0);
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
    );
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

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }

  String _getBiometricText() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face Recognition';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else {
      return 'Biometric';
    }
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
                    _buildAccessCodeField(),
                    const SizedBox(height: 30),
                    _buildLoginButtons(),
                    const SizedBox(height: 30),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildSessionInfo(),
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

  // UPDATED: Account number field with tap and change handlers
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
      onTap: () {
        // Clear the field if it contains a masked number to allow fresh input
        if (_actualAccountNumber != null &&
            _accountController.text.contains('*')) {
          _accountController.clear();
          setState(() {
            _actualAccountNumber = null;
            _showBiometricOption = false;
          });
        }
      },
      onChanged: (value) {
        // If user starts typing, clear the saved account and hide biometric option
        if (_actualAccountNumber != null) {
          setState(() {
            _actualAccountNumber = null;
            _showBiometricOption = false;
          });
        }
      },
    );
  }

  Widget _buildAccessCodeField() {
    return _CustomTextField(
      controller: _accessCodeController,
      label: 'Access Code',
      hint: 'Enter your access code',
      icon: Icons.lock_outline,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        // Regular login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                        'Login',
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
        ),

        // Biometric login button (shown only if available and enabled)
        if (_showBiometricOption &&
            _isBiometricAvailable &&
            _availableBiometrics.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(color: _primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isLoading ? null : _authenticateWithBiometrics,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getBiometricIcon(), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Login with ${_getBiometricText()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Register Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(color: _primaryColor.withOpacity(0.7)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _navigateToRegistration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Forgot Code Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: BorderSide(color: Colors.orange.withOpacity(0.7)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _navigateToForgotCode,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_reset_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Forgot Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
              _showBiometricOption
                  ? 'Use biometric authentication for faster login'
                  : 'Secure login with your account number and access code',
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
}

// UPDATED: Custom TextField widget with onTap and onChanged callbacks
class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

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
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryColor, size: 22),
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
}

// NEW: Enhanced logout function for security
void clearUserData(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // Clear all saved credentials
  await prefs.remove('biometric_enabled');
  await prefs.remove('saved_account_number');

  // Clear all user-specific data
  final keys = prefs.getKeys();
  for (String key in keys) {
    if (key.startsWith('access_code_') ||
        key.startsWith('biometrics_setup_') ||
        key.startsWith('phone_') ||
        key.startsWith('created_date_')) {
      await prefs.remove(key);
    }
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginBankingScreen()),
    (route) => false,
  );
}
