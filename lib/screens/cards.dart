import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'statement.dart';

class CardsContent extends StatefulWidget {
  final int initialCardIndex;
  final List<Map<String, dynamic>>? cardsList;

  const CardsContent({
    super.key,
    this.initialCardIndex = 0,
    this.cardsList,
  });

  @override
  State<CardsContent> createState() => _CardsContentState();
}

class _CardsContentState extends State<CardsContent>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final PageController _pageController;
  late final List<Map<String, dynamic>> _cards;

  int _currentPage = 0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // Enhanced card data with more details
  static const List<Map<String, dynamic>> _defaultCards = [
    {
      'cardNumber': '**** **** **** 2345',
      'fullCardNumber': '4532 1234 5678 2345',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '02/30',
      'cardType': 'Visa Debit Card',
      'cardNetwork': 'Visa',
      'issueDate': '02/25',
      'status': 'Active',
      'dailyLimit': 'LKR 200,000',
      'monthlyLimit': 'LKR 5,000,000',
      'balance': 'LKR 25,500.00',
      'background': LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF545877), Color(0xFF3a3d57)],
      ),
    },
    {
      'cardNumber': '**** **** **** 7890',
      'fullCardNumber': '5432 9876 5432 7890',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '05/28',
      'cardType': 'Ladies Savings Visa Debit Card',
      'cardNetwork': 'Visa',
      'issueDate': '05/23',
      'status': 'Active',
      'dailyLimit': 'LKR 300,000',
      'monthlyLimit': 'LKR 7,500,000',
      'balance': 'LKR 35,750.00',
      'background': LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6b7299), Color(0xFF4a4d6b)],
      ),
    },
    {
      'cardNumber': '**** **** **** 1122',
      'fullCardNumber': '6011 0009 9013 1122',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '12/29',
      'cardType': 'Vantage Visa Debit Card',
      'cardNetwork': 'Visa',
      'issueDate': '12/24',
      'status': 'Active',
      'dailyLimit': 'LKR 500,000',
      'monthlyLimit': 'LKR 12,000,000',
      'balance': 'LKR 89,320.00',
      'background': LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7a8099), Color(0xFF5a5d73)],
      ),
    },
    {
      'cardNumber': '**** **** **** 9876',
      'fullCardNumber': '4532 8765 4321 9876',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '08/31',
      'cardType': 'Prestige Visa Debit Card',
      'cardNetwork': 'Visa',
      'issueDate': '08/23',
      'status': 'Active',
      'dailyLimit': 'LKR 1,000,000',
      'monthlyLimit': 'LKR 25,000,000',
      'balance': 'LKR 125,680.00',
      'background': LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8a9099), Color(0xFF6a6d73)],
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _setupControllers();
  }

  void _initializeCards() {
    _cards = widget.cardsList ?? _defaultCards;
    _currentPage = widget.initialCardIndex.clamp(0, _cards.length - 1);
  }

  void _setupControllers() {
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _currentPage,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalBalanceCard(),
                  _buildSectionHeader('My Cards', _cards.length),
                  _buildCardsCarousel(),
                  _buildCardIndicators(),
                  _buildQuickActions(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return _AnimatedSlideIn(
      delay: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _containerColor.withOpacity(0.3),
              _containerColor.withOpacity(0.1),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'My Cards',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.search,
                  onPressed: _showSearchBottomSheet,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.notifications_outlined,
                  onPressed: _showNotifications,
                  showBadge: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    double totalBalance = _cards.fold(0.0, (sum, card) {
      String balanceStr =
          card['balance']?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0';
      return sum + (double.tryParse(balanceStr) ?? 0);
    });

    return _AnimatedSlideIn(
      delay: 200,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _EnhancedGlassContainer(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: _primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Available Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LKR ${totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_cards.length} Active Cards',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _PulsingWidget(
                child: _QuickActionButton(
                  icon: Icons.visibility,
                  label: 'View All',
                  onTap: _showAllCardsModal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return _AnimatedSlideIn(
      delay: 400,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 12.0),
        child: Row(
          children: [
            Container(
              height: 24,
              width: 4,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                '$count Cards',
                style: const TextStyle(
                  fontSize: 12,
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsCarousel() {
    return _AnimatedSlideIn(
      delay: 600,
      child: SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _cards.length,
          onPageChanged: (int page) {
            setState(() => _currentPage = page);
            HapticFeedback.lightImpact();
          },
          itemBuilder: (context, index) => _EnhancedCreditCard(
            cardData: _cards[index],
            index: index,
            isActive: _currentPage == index,
            onTap: () => _showCardDetails(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCardIndicators() {
    return _AnimatedSlideIn(
      delay: 800,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cards.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? _primaryColor : Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return _AnimatedSlideIn(
      delay: 1000,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.receipt_long,
                    label: 'Transactions',
                    subtitle: 'View history',
                    onTap: _navigateToStatement,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.analytics,
                    label: 'Spending',
                    subtitle: 'View insights',
                    onTap: _showSpendingAnalytics,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.lock_outline,
                    label: 'Security',
                    subtitle: 'Card controls',
                    onTap: _showSecurityOptions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.help_outline,
                    label: 'Support',
                    subtitle: 'Get help',
                    onTap: _showSupport,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navigation and modal methods
  void _navigateToStatement() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const StatementScreen(),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(1.0, 0.0);
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showCardDetails(int index) {
    _showModal(
      title: 'Card Details',
      height: 0.8,
      child: _buildCardDetailsContent(_cards[index]),
    );
  }

  void _showAllCardsModal() {
    _showModal(
      title: 'All Cards Overview',
      height: 0.75,
      child: _buildAllCardsContent(),
    );
  }

  void _showSearchBottomSheet() {
    _showModal(
      title: 'Search Transactions',
      height: 0.6,
      child: _buildSearchContent(),
    );
  }

  void _showNotifications() {
    _showModal(
      title: 'Notifications',
      height: 0.6,
      child: _buildNotificationsContent(),
    );
  }

  void _showSpendingAnalytics() {
    _showModal(
      title: 'Spending Analytics',
      height: 0.7,
      child: _buildSpendingContent(),
    );
  }

  void _showSecurityOptions() {
    _showModal(
      title: 'Security & Controls',
      height: 0.6,
      child: _buildSecurityContent(),
    );
  }

  void _showSupport() {
    _showModal(
      title: 'Support & Help',
      height: 0.6,
      child: _buildSupportContent(),
    );
  }

  void _showModal({
    required String title,
    required double height,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModalContainer(
        title: title,
        height: height,
        child: child,
      ),
    );
  }

  Widget _buildCardDetailsContent(Map<String, dynamic> card) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _DetailItem(
            icon: Icons.credit_card,
            title: 'Card Type',
            value: card['cardType'] ?? '',
          ),
          _DetailItem(
            icon: Icons.person_outline,
            title: 'Card Holder',
            value: card['cardHolder'] ?? '',
          ),
          _DetailItem(
            icon: Icons.numbers,
            title: 'Card Number',
            value: card['cardNumber'] ?? '',
          ),
          _DetailItem(
            icon: Icons.calendar_today,
            title: 'Expiry Date',
            value: card['expiryDate'] ?? '',
          ),
          _DetailItem(
            icon: Icons.date_range,
            title: 'Issue Date',
            value: card['issueDate'] ?? '',
          ),
          _DetailItem(
            icon: Icons.account_balance_wallet,
            title: 'Available Balance',
            value: card['balance'] ?? '',
          ),
          _DetailItem(
            icon: Icons.trending_up,
            title: 'Daily Limit',
            value: card['dailyLimit'] ?? '',
          ),
          _DetailItem(
            icon: Icons.show_chart,
            title: 'Monthly Limit',
            value: card['monthlyLimit'] ?? '',
          ),
          _DetailItem(
            icon: Icons.verified_outlined,
            title: 'Status',
            value: card['status'] ?? '',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: _ActionButton(
              icon: Icons.receipt_long,
              label: 'View Transactions',
              onTap: () {
                Navigator.pop(context);
                _navigateToStatement();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCardsContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _cards.length,
      itemBuilder: (context, index) => _CardSummaryItem(
        cardData: _cards[index],
        onTap: () {
          Navigator.pop(context);
          _showCardDetails(index);
        },
      ),
    );
  }

  Widget _buildSearchContent() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _SearchField(),
          SizedBox(height: 20),
          Text(
            'Search through your card transactions',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _NotificationItem(
          title: 'Transaction Alert',
          message: 'Purchase of LKR 2,450 at Amazon.com',
          time: '5 minutes ago',
          icon: Icons.shopping_cart,
        ),
        _NotificationItem(
          title: 'Security Alert',
          message: 'Your card was used for online purchase',
          time: '2 hours ago',
          icon: Icons.security,
        ),
        _NotificationItem(
          title: 'Monthly Statement',
          message: 'Your monthly statement is ready',
          time: '1 day ago',
          icon: Icons.receipt_long,
        ),
      ],
    );
  }

  Widget _buildSpendingContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SpendingCategoryItem(
            category: 'Shopping',
            amount: 'LKR 12,450',
            percentage: 45,
            color: Colors.orange,
            icon: Icons.shopping_bag,
          ),
          _SpendingCategoryItem(
            category: 'Food & Dining',
            amount: 'LKR 8,200',
            percentage: 30,
            color: Colors.green,
            icon: Icons.restaurant,
          ),
          _SpendingCategoryItem(
            category: 'Transportation',
            amount: 'LKR 4,350',
            percentage: 16,
            color: Colors.blue,
            icon: Icons.directions_car,
          ),
          _SpendingCategoryItem(
            category: 'Entertainment',
            amount: 'LKR 2,500',
            percentage: 9,
            color: Colors.purple,
            icon: Icons.movie,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SecurityOptionItem(
          title: 'Card Lock/Unlock',
          subtitle: 'Temporarily disable your card',
          icon: Icons.lock_outline,
          onTap: () {},
        ),
        _SecurityOptionItem(
          title: 'Transaction Limits',
          subtitle: 'View and manage spending limits',
          icon: Icons.account_balance_wallet,
          onTap: () {},
        ),
        _SecurityOptionItem(
          title: 'Contactless Settings',
          subtitle: 'Manage tap-to-pay preferences',
          icon: Icons.contactless,
          onTap: () {},
        ),
        _SecurityOptionItem(
          title: 'Change PIN',
          subtitle: 'Update your card PIN securely',
          icon: Icons.pin,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SupportOptionItem(
          title: 'Report Lost/Stolen Card',
          subtitle: 'Immediate card blocking',
          icon: Icons.report_problem,
          onTap: () {},
        ),
        _SupportOptionItem(
          title: 'Dispute Transaction',
          subtitle: 'Report unauthorized charges',
          icon: Icons.gavel,
          onTap: () {},
        ),
        _SupportOptionItem(
          title: 'Contact Support',
          subtitle: '24/7 customer service',
          icon: Icons.headset_mic,
          onTap: () {},
        ),
        _SupportOptionItem(
          title: 'FAQ',
          subtitle: 'Frequently asked questions',
          icon: Icons.help_outline,
          onTap: () {},
        ),
      ],
    );
  }
}

// Helper function for safe gradient handling
LinearGradient _getCardGradient(dynamic background) {
  if (background is LinearGradient) {
    // Ensure the gradient has at least 2 colors
    if (background.colors.length >= 2) {
      return background;
    }
  }

  // Return default gradient with 2 colors
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF545877), Color(0xFF2C2E40)],
  );
}

// Enhanced Components with animations
class _AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedSlideIn({required this.child, required this.delay});

  @override
  State<_AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<_AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _PulsingWidget extends StatefulWidget {
  final Widget child;

  const _PulsingWidget({required this.child});

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF00FFEB)),
            onPressed: onPressed,
          ),
        ),
        if (showBadge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _EnhancedGlassContainer extends StatelessWidget {
  const _EnhancedGlassContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.8),
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00FFEB).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FFEB).withOpacity(0.2),
                  const Color(0xFF00FFEB).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FFEB).withOpacity(0.3),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF00FFEB), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedCreditCard extends StatelessWidget {
  const _EnhancedCreditCard({
    required this.cardData,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  final Map<String, dynamic> cardData;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'creditCard$index',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()..scale(isActive ? 1.0 : 0.95),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: isActive ? 20 : 10,
              shadowColor: Colors.black.withOpacity(0.5),
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: _getCardGradient(cardData['background']),
                  border: isActive
                      ? Border.all(
                          color: const Color(0xFF00FFEB).withOpacity(0.5),
                          width: 2,
                        )
                      : null,
                ),
                child: _buildCardContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            cardData['cardNumber'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child:
                    _buildCardInfo('CARD HOLDER', cardData['cardHolder'] ?? ''),
              ),
              Expanded(
                child: _buildCardInfo('EXPIRES', cardData['expiryDate'] ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 84, 88, 119).withOpacity(0.6),
              const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00FFEB).withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFEB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00FFEB),
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSummaryItem extends StatelessWidget {
  const _CardSummaryItem({
    required this.cardData,
    required this.onTap,
  });

  final Map<String, dynamic> cardData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _getCardGradient(cardData['background']),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardData['cardType'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    cardData['cardNumber'] ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    cardData['balance'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF00FFEB)),
        filled: true,
        fillColor: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00FFEB)),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFEB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00FFEB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingCategoryItem extends StatelessWidget {
  const _SpendingCategoryItem({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  final String category;
  final String amount;
  final int percentage;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage% of total spending',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityOptionItem extends StatelessWidget {
  const _SecurityOptionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFEB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF00FFEB), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportOptionItem extends StatelessWidget {
  const _SupportOptionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFEB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF00FFEB), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFEB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00FFEB), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFEB),
        foregroundColor: const Color(0xFF0F0027),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalContainer extends StatelessWidget {
  const _ModalContainer({
    required this.title,
    required this.height,
    required this.child,
  });

  final String title;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * height,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0027),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF00FFEB),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
