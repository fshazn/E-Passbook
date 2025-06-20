// otp_verification_screen.dart
import 'package:e_pass_app/screens/bottom_navbar.dart';
import 'package:e_pass_app/screens/login_banking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
//import 'login_page.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String accountNumber;
  final String cif;
  final bool isRegistration;
  final bool isForgotCode;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.accountNumber,
    required this.cif,
    this.isRegistration = false,
    this.isForgotCode = false,
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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_currentOTP.length == 6) {
      _verifyOTP();
    }
  }

  void _verifyOTP() {
    if (_currentOTP.length != 6) {
      _showErrorMessage('Please enter complete OTP');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        setState(() => _isLoading = false);

        if (_currentOTP == '123456' || _currentOTP.length == 6) {
          if (widget.isRegistration) {
            await _completeRegistration();
          } else if (widget.isForgotCode) {
            await _resetAccessCode();
          } else {
            _navigateToAccounts();
          }
        } else {
          _showErrorAndShake('Invalid OTP. Please try again.');
          _clearOTP();
        }
      }
    });
  }

  Future<void> _completeRegistration() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final registeredCIFs = prefs.getStringList('registered_cifs') ?? [];
      registeredCIFs.add(widget.cif);
      await prefs.setStringList('registered_cifs', registeredCIFs);

      await prefs.setString('phone_${widget.cif}', widget.phoneNumber);
      await prefs.setString(
          'created_date_${widget.cif}', DateTime.now().toIso8601String());

      _showSuccessMessage('Registration completed successfully!');

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => const LoginBankingScreen(),
          transitionsBuilder: (context, animation, _, child) {
            const begin = Offset(-1.0, 0.0);
            final tween = Tween(begin: begin, end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
        (route) => false,
      );
    } catch (e) {
      _showErrorMessage('Registration failed. Please try again.');
    }
  }

  Future<void> _resetAccessCode() async {
    try {
      final newAccessCode =
          DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_code_${widget.cif}', newAccessCode);
      _showSuccessDialog(newAccessCode);
    } catch (e) {
      _showErrorMessage('Failed to reset access code. Please try again.');
    }
  }

  void _showSuccessDialog(String newCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _containerColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: _primaryColor),
            SizedBox(width: 12),
            Text('Access Code Reset', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your new access code is:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryColor),
              ),
              child: Text(
                newCode,
                style: const TextStyle(
                  color: _primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please save this code safely. You will need it to login.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginBankingScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
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
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _startTimer();
        _clearOTP();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New OTP sent to ${widget.phoneNumber}'),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 48),
                        _buildOTPInput(),
                        const SizedBox(height: 32),
                        _buildTimerSection(),
                        const SizedBox(height: 32),
                        _buildVerifyButton(),
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
          Expanded(
            child: Text(
              widget.isRegistration
                  ? 'Complete Registration'
                  : widget.isForgotCode
                      ? 'Reset Access Code'
                      : 'Verify OTP',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
            Icons.message,
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
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            children: [
              const TextSpan(text: 'We sent a 6-digit code to\n'),
              TextSpan(
                text: widget.phoneNumber,
                style: const TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: '\nCIF: '),
              TextSpan(
                text: widget.cif,
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
              Icon(Icons.timer, color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 8),
              Text(
                'Resend code in ${_formatTime(_remainingTime)}',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: _primaryColor, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: _primaryColor,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          disabledBackgroundColor: _primaryColor.withOpacity(0.3),
        ),
        onPressed: (_isLoading || _currentOTP.length != 6) ? null : _verifyOTP,
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.black, strokeWidth: 2)
            : Text(
                widget.isRegistration
                    ? 'Complete Registration'
                    : widget.isForgotCode
                        ? 'Reset Code'
                        : 'Verify & Continue',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            HapticFeedback.lightImpact();
          }
          onChanged(value);
        },
        onTap: () {
          if (controller.text.isNotEmpty) {
            controller.clear();
            onChanged('');
          }
        },
      ),
    );
  }
}
