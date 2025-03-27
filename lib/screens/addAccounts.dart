import 'package:flutter/material.dart';
import 'dart:ui';

class AddAccountsScreen extends StatefulWidget {
  const AddAccountsScreen({Key? key}) : super(key: key);

  @override
  State<AddAccountsScreen> createState() => _AddAccountsScreenState();
}

class _AddAccountsScreenState extends State<AddAccountsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final _formKey = GlobalKey<FormState>();
  String _selectedAccountType = 'Savings Account';
  bool _isLoading = false;

  // List of account types
  final List<Map<String, dynamic>> _accountTypes = [
    {
      'name': 'Savings Account',
      'icon': Icons.savings,
      'description': 'Regular savings account with standard interest rates'
    },
    {
      'name': 'Current Account',
      'icon': Icons.account_balance,
      'description': 'Day-to-day transactions with no interest'
    },
    {
      'name': 'Fixed Deposit',
      'icon': Icons.lock_clock,
      'description': 'Higher interest rates for fixed term deposits'
    },
    {
      'name': 'Term Investment',
      'icon': Icons.trending_up,
      'description': 'Long-term investment with competitive returns'
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account added successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF0F0027),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: const Color(0xFF00FFEB),
              onPressed: () {},
            ),
          ),
        );

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Add New Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00FFEB),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: const Color(0xFF00FFEB)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SafeArea(
          child: Stack(
            children: [
              // Background elements for visual interest
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00FFEB).withOpacity(0.03),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00FFEB).withOpacity(0.02),
                  ),
                ),
              ),

              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00FFEB),
                                    const Color(0xFF00FFEB).withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FFEB)
                                        .withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(flex: 3, child: Container()),
                        ],
                      ),
                    ),

                    // Select Account Type Section
                    _buildSectionHeader('Select Account Type'),
                    const SizedBox(height: 15),

                    // Account type selection cards
                    ...List.generate(
                      _accountTypes.length,
                      (index) => _buildAccountTypeCard(
                        _accountTypes[index]['name'],
                        _accountTypes[index]['icon'],
                        _accountTypes[index]['description'],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Account Details Form Section
                    _buildSectionHeader('Account Details'),
                    const SizedBox(height: 15),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Account Number',
                            hint: 'Enter your account number',
                            icon: Icons.account_balance,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your account number';
                              } else if (value.length < 10) {
                                return 'Account number should be at least 10 digits';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 15),

                          _buildTextField(
                            label: 'Branch',
                            hint: 'Select your branch',
                            icon: Icons.location_on_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your branch';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          _buildTextField(
                            label: 'Account Nickname (Optional)',
                            hint: 'E.g., Savings, Emergency Fund',
                            icon: Icons.label_outline,
                            validator: (value) {
                              return null; // Optional field
                            },
                          ),

                          const SizedBox(height: 40),

                          // Primary action button (full width)
                          _buildActionButton(
                            label: 'Add Account',
                            icon: Icons.check_circle_outline,
                            isPrimary: true,
                            isLoading: _isLoading,
                            onTap: _submitForm,
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 18,
          width: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF00FFEB),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFEB),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeCard(String name, IconData icon, String description) {
    final isSelected = _selectedAccountType == name;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF00FFEB) : Colors.transparent,
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  const Color(0xFF545877).withOpacity(0.9),
                  const Color(0xFF545877).withOpacity(0.6),
                ]
              : [
                  const Color(0xFF545877).withOpacity(0.7),
                  const Color(0xFF545877).withOpacity(0.4),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF00FFEB).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedAccountType = name;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFEB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF00FFEB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF00FFEB).withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00FFEB)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            Icons.check,
                            color: const Color(0xFF00FFEB),
                            size: 16,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: TextFormField(
            style: const TextStyle(color: Colors.white),
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF00FFEB).withOpacity(0.7),
                size: 20,
              ),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorStyle: TextStyle(
                color: Colors.red[300],
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = true,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00FFEB),
                    const Color(0xFF00FFEB).withOpacity(0.8),
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? Colors.transparent : const Color(0xFF00FFEB),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF00FFEB).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary
                          ? const Color(0xFF0F0027)
                          : const Color(0xFF00FFEB),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isPrimary
                          ? const Color(0xFF0F0027)
                          : const Color(0xFF00FFEB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isPrimary
                            ? const Color(0xFF0F0027)
                            : const Color(0xFF00FFEB),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
