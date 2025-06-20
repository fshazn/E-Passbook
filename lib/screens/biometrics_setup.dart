// biometrics_setup.dart
import 'package:e_pass_app/screens/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsSetup extends StatefulWidget {
  final String accountNumber;
  final String cif;
  final String accessCode;

  const BiometricsSetup({
    super.key,
    required this.accountNumber,
    required this.cif,
    required this.accessCode,
  });

  @override
  State<BiometricsSetup> createState() => _BiometricsSetupState();
}

class _BiometricsSetupState extends State<BiometricsSetup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;
  late final LocalAuthentication _localAuth;

  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);

  @override
  void initState() {
    super.initState();
    _localAuth = LocalAuthentication();
    _setupAnimations();
    _initializeBiometrics();
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

  Future<void> _initializeBiometrics() async {
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics;
      if (_isBiometricAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing biometrics: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _enableBiometrics() async {
    setState(() => _isLoading = true);

    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Set up biometric authentication for faster login',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', true);
        await prefs.setBool('biometrics_setup_${widget.cif}', true);
        await prefs.setString('saved_account_number', widget.accountNumber);
        await prefs.setString('access_code_${widget.cif}', widget.accessCode);

        _showSuccessSnackBar('Biometric authentication enabled successfully!');
        _navigateToAccounts();
      } else {
        _showErrorSnackBar('Biometric setup was cancelled');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to enable biometric authentication');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_setup_${widget.cif}', true);
    await prefs.setString('access_code_${widget.cif}', widget.accessCode);
    _navigateToAccounts();
  }

  void _navigateToAccounts() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) =>
            const MainScreen(), // Changed from AccountsContent
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 60),
                        _buildFeatures(),
                        const SizedBox(height: 40),
                        _buildButtons(),
                      ],
                    ),
                  ),
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryColor.withOpacity(0.1),
            border: Border.all(color: _primaryColor, width: 2),
          ),
          child: Icon(
            _getBiometricIcon(),
            color: _primaryColor,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enable Biometric Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Use ${_getBiometricText().toLowerCase()} for faster and more secure access',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'CIF: ${widget.cif}',
          style: TextStyle(
            color: _primaryColor.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildFeatureItem(Icons.speed, 'Quick Login', 'Access in seconds'),
          const SizedBox(height: 16),
          _buildFeatureItem(
              Icons.security, 'Enhanced Security', 'Data stays on device'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    if (!_isBiometricAvailable || _availableBiometrics.isEmpty) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Biometric authentication not available',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _skipBiometrics,
              child: const Text(
                'Continue to Accounts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isLoading ? null : _enableBiometrics,
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getBiometricIcon(), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Enable ${_getBiometricText()}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white70.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _skipBiometrics,
            child: const Text(
              'Maybe Later',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      'You can enable biometric login later in settings',
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}
