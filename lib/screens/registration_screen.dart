// registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _accountController;
  late final TextEditingController _phoneController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;

  bool _isLoading = false;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController();
    _phoneController = TextEditingController();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    _phoneController.dispose();
    super.dispose();
  }

  String _extractCIF(String accountNumber) {
    if (accountNumber.length >= 7) {
      return accountNumber.substring(accountNumber.length - 7);
    }
    return accountNumber;
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

    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return false;
    }

    if (_phoneController.text.length < 10) {
      _showErrorSnackBar('Please enter a valid phone number');
      return false;
    }

    return true;
  }

  Future<bool> _checkIfAlreadyRegistered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cif = _extractCIF(_accountController.text);
      final registeredCIFs = prefs.getStringList('registered_cifs') ?? [];
      return registeredCIFs.contains(cif);
    } catch (e) {
      debugPrint('Error checking registration: $e');
      return false;
    }
  }

  void _proceedToOTP() async {
    if (!_validateInput()) return;

    setState(() => _isLoading = true);

    try {
      final isAlreadyRegistered = await _checkIfAlreadyRegistered();
      if (isAlreadyRegistered) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Account already registered. Please login instead.');
        return;
      }

      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => OTPVerificationScreen(
            phoneNumber: _phoneController.text,
            accountNumber: _accountController.text,
            cif: _extractCIF(_accountController.text),
            isRegistration: true,
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
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Registration failed. Please try again.');
    }
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: FadeTransition(
          opacity: _fadeInAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 48),
                        _buildInputFields(),
                        const SizedBox(height: 32),
                        _buildContinueButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: _primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryColor.withOpacity(0.1),
            border: Border.all(color: _primaryColor, width: 2),
          ),
          child: const Icon(
            Icons.person_add,
            color: _primaryColor,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Register for E-Passbook',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your account details to get started',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _accountController,
          label: 'Account Number',
          icon: Icons.account_balance,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        inputFormatters: keyboardType == TextInputType.number ||
                keyboardType == TextInputType.phone
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryColor),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          floatingLabelStyle: const TextStyle(color: _primaryColor),
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isLoading ? null : _proceedToOTP,
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              )
            : const Text(
                'Send OTP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
