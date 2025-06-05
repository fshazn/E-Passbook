import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class CardWheelWidget extends StatefulWidget {
  final List<Map<String, dynamic>> cards;
  final String Function(double) formatCurrency;

  const CardWheelWidget({
    super.key,
    required this.cards,
    required this.formatCurrency,
  });

  @override
  State<CardWheelWidget> createState() => _CardWheelWidgetState();
}

class _CardWheelWidgetState extends State<CardWheelWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  double _totalRotation = 0.0;
  bool _isRotating = false;
  double _dragStartAngle = 0.0;
  double _tempRotation = 0.0;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isRotating) return;
    _dragStartAngle = _totalRotation;
    _tempRotation = _totalRotation;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isRotating) return;

    // Calculate rotation based on horizontal drag with better sensitivity
    final sensitivity = 0.015;
    final deltaRotation = details.delta.dx * sensitivity;

    setState(() {
      _tempRotation += deltaRotation;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isRotating) return;

    final totalDelta = _tempRotation - _dragStartAngle;

    // Always snap to the nearest card position
    final anglePerCard = 2 * math.pi / widget.cards.length;
    final steps = (totalDelta / anglePerCard).round();
    final targetRotation = _dragStartAngle + (steps * anglePerCard);

    _animateToRotation(targetRotation);
  }

  void _animateToRotation(double targetRotation) async {
    if (_isRotating) return;

    setState(() {
      _isRotating = true;
    });

    HapticFeedback.lightImpact();

    final rotationTween = Tween<double>(
      begin: _tempRotation,
      end: targetRotation,
    ).animate(_rotationAnimation);

    listener() {
      setState(() {
        _totalRotation = rotationTween.value;
        _tempRotation = rotationTween.value;
      });
    }

    rotationTween.addListener(listener);

    await _rotationController.forward();

    rotationTween.removeListener(listener);

    setState(() {
      _totalRotation = targetRotation;
      _tempRotation = targetRotation;
      _isRotating = false;
    });

    _rotationController.reset();
  }

  int _getCurrentFrontCardIndex() {
    final anglePerCard = 2 * math.pi / widget.cards.length;
    final currentRotation = _isRotating ? _totalRotation : _tempRotation;

    // Normalize rotation to 0-2π range
    final normalizedRotation =
        ((-currentRotation) % (2 * math.pi) + 2 * math.pi) % (2 * math.pi);

    // Calculate which card is at front (angle 0)
    final frontIndex =
        (normalizedRotation / anglePerCard + 0.5).floor() % widget.cards.length;
    return frontIndex;
  }

  Widget _buildCard(Map<String, dynamic> card, int index) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Blue
      [const Color(0xFF10B981), const Color(0xFF059669)], // Green
      [const Color(0xFFEF4444), const Color(0xFFF97316)], // Red-Orange
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)], // Purple-Pink
      [const Color(0xFFFFD700), const Color(0xFFFF8C00)], // Gold
    ];

    final cardGradient = gradients[index % gradients.length];

    // Calculate position on the wheel
    final anglePerCard = 2 * math.pi / widget.cards.length;
    final currentRotation = _isRotating ? _totalRotation : _tempRotation;
    final cardAngle = currentRotation + (index * anglePerCard);

    final radius = 80.0;
    final x = math.sin(cardAngle) * radius;
    final y = math.cos(cardAngle) * radius * 0.15; // Minimal vertical offset

    // Calculate depth (how close to front)
    final depth = math.cos(cardAngle);
    final normalizedDepth = (depth + 1) / 2; // Convert to 0-1 range

    // Better visual properties for clarity
    final scale = 0.85 + (normalizedDepth * 0.15);
    final opacity = 0.88 + (normalizedDepth * 0.12); // Much less transparent

    // Check if this is the front card
    final frontIndex = _getCurrentFrontCardIndex();
    final isFrontCard = index == frontIndex;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseScale = isFrontCard ? _pulseAnimation.value : 1.0;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..translate(x, y)
            ..scale(scale * pulseScale),
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onTap: () {
                if (!isFrontCard) {
                  // Calculate rotation to bring this card to front
                  final currentFront = _getCurrentFrontCardIndex();
                  final cardCount = widget.cards.length;
                  final anglePerCard = 2 * math.pi / cardCount;

                  // Calculate shortest path
                  final forwardSteps =
                      (index - currentFront + cardCount) % cardCount;
                  final backwardSteps =
                      (currentFront - index + cardCount) % cardCount;

                  final steps = forwardSteps <= backwardSteps
                      ? forwardSteps
                      : -backwardSteps;
                  final targetRotation =
                      _totalRotation - (steps * anglePerCard);

                  _animateToRotation(targetRotation);
                }
              },
              child: Container(
                width: 260,
                height: 170,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: cardGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cardGradient[0].withOpacity(0.2),
                      blurRadius: isFrontCard ? 15 : 8,
                      offset: Offset(0, isFrontCard ? 8 : 4),
                      spreadRadius: isFrontCard ? 2 : 1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Sparkle effects for front card (reduced)
                    if (isFrontCard) ...[
                      ...List.generate(3, (i) {
                        final positions = [
                          const Offset(40, 30),
                          const Offset(120, 25),
                          const Offset(200, 35),
                        ];
                        return Positioned(
                          left: positions[i].dx,
                          top: positions[i].dy,
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ],

                    // Card content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card['bankName'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isFrontCard ? 16 : 14,
                                        fontWeight: FontWeight.w700,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                            color:
                                                Colors.black.withOpacity(0.6),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      card['cardType'],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontSize: isFrontCard ? 13 : 11,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 1),
                                            blurRadius: 3,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.contactless,
                                  color: Colors.white,
                                  size: isFrontCard ? 20 : 16,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            card['cardNumber'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isFrontCard ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card['cardHolder'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isFrontCard ? 14 : 12,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 1),
                                            blurRadius: 3,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Exp: ${card['expiryDate']}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: isFrontCard ? 12 : 10,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 1),
                                            blurRadius: 3,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                widget.formatCurrency(card['balance']),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isFrontCard ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Simple front card indicator (no glow)
                    if (isFrontCard)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4FC3F7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final frontCardIndex = _getCurrentFrontCardIndex();

    return Column(
      children: [
        // Card wheel container
        GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Render cards in order of depth (back to front)
                for (int i = 0; i < widget.cards.length; i++)
                  _buildCard(widget.cards[i], i),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Simple card counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3F7).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4FC3F7),
              width: 1,
            ),
          ),
          child: Text(
            '${frontCardIndex + 1} / ${widget.cards.length}',
            style: const TextStyle(
              color: Color(0xFF4FC3F7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// Main widget using the fixed wheel
class BankingHomeScreen extends StatefulWidget {
  const BankingHomeScreen({super.key});

  @override
  State<BankingHomeScreen> createState() => _BankingHomeScreenState();
}

class _BankingHomeScreenState extends State<BankingHomeScreen> {
  String selectedBalanceType = 'Total';
  bool isBalanceVisible = true;

  // Sample data
  static const List<Map<String, dynamic>> _cardsList = [
    {
      'cardNumber': '**** **** **** 2345',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '02/30',
      'balance': 15420.50,
      'cardType': 'Debit Card',
      'bankName': 'Dhaka Bank Ltd'
    },
    {
      'cardNumber': '**** **** **** 6789',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '05/28',
      'balance': 8750.25,
      'cardType': 'Credit Card',
      'bankName': 'Commercial Bank'
    },
    {
      'cardNumber': '**** **** **** 1234',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '12/29',
      'balance': 32150.75,
      'cardType': 'Premium Card',
      'bankName': 'Prime Bank Ltd'
    },
  ];

  static const List<Map<String, dynamic>> _accountsList = [
    {
      'accountName': 'Current Account',
      'accountNumber': '****4521',
      'balance': 25680.30,
      'bankName': 'Dhaka Bank Ltd',
      'accountType': 'Current'
    },
    {
      'accountName': 'Savings Account',
      'accountNumber': '****7845',
      'balance': 45320.75,
      'bankName': 'Standard Bank',
      'accountType': 'Savings'
    },
    {
      'accountName': 'Investment Account',
      'accountNumber': '****9632',
      'balance': 78450.25,
      'bankName': 'Investment Bank',
      'accountType': 'Investment'
    },
  ];

  static const List<Map<String, dynamic>> _transactionsList = [
    {
      'name': 'Salary Payment',
      'date': 'Today, 09:30 AM',
      'amount': 5500.00,
      'type': 'income',
      'status': 'Completed'
    },
    {
      'name': 'Shopping Mall',
      'date': 'Yesterday, 03:45 PM',
      'amount': -245.50,
      'type': 'expense',
      'status': 'Completed'
    },
    {
      'name': 'Restaurant Dinner',
      'date': 'May 23, 07:20 PM',
      'amount': -85.25,
      'type': 'expense',
      'status': 'Completed'
    },
    {
      'name': 'Investment Return',
      'date': 'May 22, 11:15 AM',
      'amount': 1250.00,
      'type': 'income',
      'status': 'Completed'
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  double _getTotalBalance() {
    switch (selectedBalanceType) {
      case 'Cards':
        return _cardsList.fold(0.0, (sum, card) => sum + card['balance']);
      case 'Accounts':
        return _accountsList.fold(
            0.0, (sum, account) => sum + account['balance']);
      default: // Total
        final cardTotal =
            _cardsList.fold(0.0, (sum, card) => sum + card['balance']);
        final accountTotal =
            _accountsList.fold(0.0, (sum, account) => sum + account['balance']);
        return cardTotal + accountTotal;
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  void _toggleBalanceType(String type) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedBalanceType = type;
    });
  }

  Widget _buildGlassMorphismContainer({
    required Widget child,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Fathima Shazna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4FC3F7),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4FC3F7).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF1E1E2E),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF4FC3F7),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Balance Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildGlassMorphismContainer(
                child: Column(
                  children: [
                    // Balance Selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: ['Total', 'Cards', 'Accounts'].map((type) {
                          final isSelected = selectedBalanceType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _toggleBalanceType(type),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF4FC3F7)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  type,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Balance Display
                    Text(
                      '$selectedBalanceType Balance',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            isBalanceVisible
                                ? _formatCurrency(_getTotalBalance())
                                : '••••••••',
                            key: ValueKey(isBalanceVisible),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              isBalanceVisible = !isBalanceVisible;
                            });
                          },
                          child: Icon(
                            isBalanceVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // My Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'My Cards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Card Wheel Widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CardWheelWidget(
                cards: _cardsList,
                formatCurrency: _formatCurrency,
              ),
            ),

            const SizedBox(height: 30),

            // My Accounts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'My Accounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _accountsList.length,
                itemBuilder: (context, index) {
                  final account = _accountsList[index];
                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                        right: index < _accountsList.length - 1 ? 15 : 0),
                    child: _buildGlassMorphismContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                account['accountName'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                account['accountNumber'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            _formatCurrency(account['balance']),
                            style: const TextStyle(
                              color: Color(0xFF4FC3F7),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            account['bankName'],
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Recent Transactions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Recent Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildGlassMorphismContainer(
                child: Column(
                  children: [
                    ...List.generate(_transactionsList.length, (index) {
                      final transaction = _transactionsList[index];
                      final isIncome = transaction['type'] == 'income';

                      return Container(
                        margin: EdgeInsets.only(
                            bottom:
                                index < _transactionsList.length - 1 ? 15 : 0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                                    : const Color(0xFFf44336).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isIncome
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFf44336),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    transaction['date'],
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIncome ? '+' : ''}${_formatCurrency(transaction['amount'])}',
                                  style: TextStyle(
                                    color: isIncome
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFf44336),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF4FC3F7),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'View All Transactions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
