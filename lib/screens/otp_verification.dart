import 'package:e_pass_app/screens/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
//import 'main_screen.dart'; // Import the main screen with bottom navigation

class OTPVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final String? accountNumber; // Add account number for session tracking

  const OTPVerificationScreen({
    super.key,
    required this.mobileNumber,
    this.accountNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _shakeController;
  late final Animation<double> _fadeInAnimation;
  late final Animation<double> _shakeAnimation;

  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _remainingTime = 30;
  bool _isLoading = false;
  bool _canResend = false;
  String _currentOTP = '';

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _animationController.forward();
  }

  void _startTimer() {
    _remainingTime = 30;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _timer?.cancel();

    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _onOTPChanged(String value, int index) {
    setState(() {
      _currentOTP = _otpControllers.map((c) => c.text).join();
    });

    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field if current is empty
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (_currentOTP.length == 6) {
      _verifyOTP();
    }
  }

  // Save verified session to SharedPreferences
  Future<void> _saveVerifiedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _generateSessionKey();
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // Save session with timestamp (valid for 30 days)
      await prefs.setInt('verified_session_$sessionKey', currentTime);
      await prefs.setString('last_verified_mobile', widget.mobileNumber);
      if (widget.accountNumber != null) {
        await prefs.setString('last_verified_account', widget.accountNumber!);
      }

      // Clean up old sessions (optional)
      await _cleanupOldSessions(prefs);
    } catch (e) {
      debugPrint('Error saving verified session: $e');
    }
  }

  // Generate unique session key based on device and account info
  String _generateSessionKey() {
    final mobile = widget.mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final account = widget.accountNumber ?? '';
    return '${mobile}_${account}_session'.toLowerCase();
  }

  // Clean up sessions older than 30 days
  Future<void> _cleanupOldSessions(SharedPreferences prefs) async {
    final keys = prefs.getKeys();
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;

    for (final key in keys) {
      if (key.startsWith('verified_session_')) {
        final timestamp = prefs.getInt(key);
        if (timestamp != null && timestamp < thirtyDaysAgo) {
          await prefs.remove(key);
        }
      }
    }
  }

  // Check if current session is already verified
  static Future<bool> isSessionVerified(String mobileNumber,
      [String? accountNumber]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final account = accountNumber ?? '';
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

  // Clear verified session (for logout)
  static Future<void> clearVerifiedSession(String mobileNumber,
      [String? accountNumber]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final account = accountNumber ?? '';
      final sessionKey = '${mobile}_${account}_session'.toLowerCase();

      await prefs.remove('verified_session_$sessionKey');
      await prefs.remove('last_verified_mobile');
      await prefs.remove('last_verified_account');
    } catch (e) {
      debugPrint('Error clearing verified session: $e');
    }
  }

  void _verifyOTP() {
    if (_currentOTP.length != 6) {
      _showErrorMessage('Please enter complete OTP');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        setState(() => _isLoading = false);

        // For demo purposes, accept any 6-digit OTP
        // In real app, verify with backend
        if (_currentOTP == '123456' || _currentOTP.length == 6) {
          // Save verified session before navigating
          await _saveVerifiedSession();
          _navigateToMainApp();
        } else {
          _showErrorAndShake('Invalid OTP. Please try again.');
          _clearOTP();
        }
      }
    });
  }

  void _navigateToMainApp() {
    // Clear the entire navigation stack and navigate to main app
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const MainScreen(),
        transitionsBuilder: (context, animation, _, child) {
          // Slide up animation
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeOutCubic));

          // Add fade effect for smoother transition
          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
      (route) => false, // Remove all previous routes
    );

    // Add success feedback
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Welcome to E-Pass Banking!'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showErrorAndShake(String message) {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });

    _showErrorMessage(message);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    setState(() => _currentOTP = '');
    _focusNodes[0].requestFocus();
  }

  void _resendOTP() {
    if (!_canResend) return;

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Simulate API call to resend OTP
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _startTimer();
        _clearOTP();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.sms, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('New OTP sent to ${widget.mobileNumber}'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildOTPInput(),
                        const SizedBox(height: 30),
                        _buildTimerSection(),
                        const SizedBox(height: 30),
                        _buildVerifyButton(),
                        const SizedBox(height: 20),
                        _buildHelpSection(),
                        const SizedBox(height: 20),
                        _buildSessionInfo(),
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
              'Verify OTP',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryColor.withOpacity(0.1),
            border: Border.all(color: _primaryColor, width: 2),
          ),
          child: const Icon(
            Icons.message_outlined,
            color: _primaryColor,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enter Verification Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'We sent a 6-digit code to\n'),
              TextSpan(
                text: widget.mobileNumber,
                style: const TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
            Icons.info_outline,
            color: _primaryColor.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'After verification, you won\'t need OTP for 30 days on this device',
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

  Widget _buildOTPInput() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeAnimation.value *
            10 *
            ((_shakeController.status == AnimationStatus.reverse) ? -1 : 1);

        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return _OTPDigitField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) => _onOTPChanged(value, index),
            isActive: _focusNodes[index].hasFocus,
          );
        }),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        if (!_canResend) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Resend code in ${_formatTime(_remainingTime)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ] else ...[
          GestureDetector(
            onTap: _resendOTP,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, color: _primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildVerifyButton() {
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
          disabledBackgroundColor: _primaryColor.withOpacity(0.3),
        ),
        onPressed: (_isLoading || _currentOTP.length != 6) ? null : _verifyOTP,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Verify & Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Handle SMS issues
                _showHelpDialog();
              },
              child: Text(
                'Having trouble?',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _containerColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Need Help?',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'If you\'re not receiving the OTP:\n\n'
          '• Check your mobile network\n'
          '• Ensure you entered the correct number\n'
          '• Contact customer service: 1234\n'
          '• Try resending after the timer expires',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }
}

// Individual OTP digit input field
class _OTPDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final bool isActive;

  const _OTPDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00FFEB)
              : controller.text.isNotEmpty
                  ? const Color(0xFF00FFEB).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF00FFEB).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          // Provide haptic feedback
          if (value.isNotEmpty) {
            HapticFeedback.lightImpact();
          }
          onChanged(value);
        },
        onTap: () {
          // Clear field when tapped for better UX
          if (controller.text.isNotEmpty) {
            controller.clear();
            onChanged('');
          }
        },
      ),
    );
  }
}
