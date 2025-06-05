import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'accounts.dart';
import 'cards.dart';
import 'facilities.dart';
import 'profile.dart';
import 'statement.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen2>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);

  static const List<Widget> _pages = [
    HomeContent(),
    AccountsScreen(),
    CardsScreen(),
    FacilitiesScreen(),
    ProfileScreen(),
  ];

  static const List<TabData> _tabsData = [
    TabData(Icons.home_rounded, 'Home'),
    TabData(Icons.account_balance_rounded, 'Accounts'),
    TabData(Icons.credit_card_rounded, 'Cards'),
    TabData(Icons.business_rounded, 'Facilities'),
    TabData(Icons.person_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _setupTabController();
  }

  void _setupTabController() {
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() => _selectedIndex = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        extendBody: true,
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: TabBar(
          controller: _tabController,
          indicatorColor: _primaryColor,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: _primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: _tabsData
              .map((tab) => Tab(icon: Icon(tab.icon), text: tab.label))
              .toList(),
        ),
      ),
    );
  }
}

class TabData {
  const TabData(this.icon, this.label);
  final IconData icon;
  final String label;
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final AnimationController _cardsController;
  late final AnimationController _accountsController;
  late final AnimationController _facilitiesController;
  late final AnimationController _transactionsController;
  late final PageController _cardPageController;

  bool _isBalanceVisible = true;
  int _currentCardIndex = 0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color(0xFF545877);

  // Sample data
  static const List<AccountSummary> _accounts = [
    AccountSummary(
      name: 'Primary Savings',
      accountNumber: '****1234',
      balance: '45,280.50',
      type: 'Savings',
      icon: Icons.savings,
    ),
    AccountSummary(
      name: 'Current Account',
      accountNumber: '****5678',
      balance: '12,540.75',
      type: 'Current',
      icon: Icons.account_balance,
    ),
    AccountSummary(
      name: 'Fixed Deposit',
      accountNumber: '****9012',
      balance: '1,00,000.00',
      type: 'FD',
      icon: Icons.timeline,
    ),
  ];

  static const List<CardSummary> _cards = [
    CardSummary(
      cardNumber: '**** **** **** 2345',
      cardHolder: 'F. S. Ismail',
      expiryDate: '02/30',
      cardType: 'Debit Card',
      limit: '50,000',
      spent: '12,450',
      background: 'assets/images/debitcard1.png',
    ),
    CardSummary(
      cardNumber: '**** **** **** 7890',
      cardHolder: 'F. S. Ismail',
      expiryDate: '05/28',
      cardType: 'Credit Card',
      limit: '2,50,000',
      spent: '85,600',
      background: 'assets/images/prestigecard1.png',
    ),
  ];

  static const List<FacilitySummary> _facilities = [
    FacilitySummary(
      name: 'Home Loan',
      amount: '25,00,000',
      emi: '22,500',
      nextDue: 'Mar 10, 2025',
      icon: Icons.home,
      status: 'Active',
    ),
    FacilitySummary(
      name: 'Personal Loan',
      amount: '5,00,000',
      emi: '8,750',
      nextDue: 'Mar 15, 2025',
      icon: Icons.person,
      status: 'Active',
    ),
  ];

  static const List<TransactionData> _transactions = [
    TransactionData(
      name: 'Salary Credit',
      date: 'Today, 9:30 AM',
      amount: '+75,000',
      isIncome: true,
      reference: 'SAL05032025',
      category: 'Salary',
      description: 'Monthly Salary Credit',
      icon: Icons.work,
    ),
    TransactionData(
      name: 'Grocery Shopping',
      date: 'Yesterday, 3:15 PM',
      amount: '-2,450',
      isIncome: false,
      reference: 'GRO04032025',
      category: 'Shopping',
      description: 'Weekly Groceries',
      icon: Icons.shopping_cart,
    ),
    TransactionData(
      name: 'ATM Withdrawal',
      date: 'Mar 3, 6:45 PM',
      amount: '-5,000',
      isIncome: false,
      reference: 'ATM03032025',
      category: 'Cash',
      description: 'Cash Withdrawal',
      icon: Icons.local_atm,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupPageController();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _accountsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _facilitiesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _transactionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _setupPageController() {
    _cardPageController = PageController(viewportFraction: 0.85);
    _cardPageController.addListener(_onPageChanged);
  }

  void _startAnimationSequence() async {
    await _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _accountsController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _facilitiesController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _transactionsController.forward();
  }

  void _onPageChanged() {
    if (_cardPageController.page != null && mounted) {
      final newIndex = _cardPageController.page!.round();
      if (newIndex != _currentCardIndex) {
        setState(() => _currentCardIndex = newIndex);
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _accountsController.dispose();
    _facilitiesController.dispose();
    _transactionsController.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  void _toggleBalanceVisibility() {
    setState(() => _isBalanceVisible = !_isBalanceVisible);
    HapticFeedback.lightImpact();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _headerController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _headerController,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF545877), Color(0xFF2C2E40)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const Spacer(),
                          _buildBalanceSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 16,
                  color: _primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fathima Shazna',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildActionButton(
              _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
              _toggleBalanceVisibility,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              Icons.notifications_outlined,
              () => _navigateToProfile(),
            ),
            const SizedBox(width: 8),
            _buildProfileAvatar(),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: _primaryColor, size: 20),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () => _navigateToProfile(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              _primaryColor.withOpacity(0.3),
              _primaryColor.withOpacity(0.1),
            ],
          ),
          border: Border.all(color: _primaryColor, width: 2),
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Portfolio',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isBalanceVisible ? 'LKR 6,82,821.25' : 'LKR ••••••••••',
            key: ValueKey(_isBalanceVisible),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Cards Section with Carousel Animation
            _buildCardsSection(),
            const SizedBox(height: 32),

            // Accounts Section with Slide-in Animation
            _buildAccountsSection(),
            const SizedBox(height: 32),

            // Facilities Section with Scale Animation
            _buildFacilitiesSection(),
            const SizedBox(height: 32),

            // Transactions Section with Fade-up Animation
            _buildTransactionsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _cardsController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _cardsController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('My Cards'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _cardPageController,
                    itemCount: _cards.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _ModernCreditCard(
                        cardData: _cards[index],
                        index: index,
                        isBalanceVisible: _isBalanceVisible,
                        onTap: () => _navigateToCards(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCardIndicators(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountsSection() {
    return AnimatedBuilder(
      animation: _accountsController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _accountsController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _accountsController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('My Accounts'),
                const SizedBox(height: 16),
                ..._accounts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final account = entry.value;
                  return _StaggeredAccountCard(
                    account: account,
                    delay: index * 100,
                    controller: _accountsController,
                    isBalanceVisible: _isBalanceVisible,
                    onTap: () => _navigateToAccounts(),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFacilitiesSection() {
    return AnimatedBuilder(
      animation: _facilitiesController,
      builder: (context, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _facilitiesController,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: _facilitiesController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Banking Facilities'),
                const SizedBox(height: 16),
                ..._facilities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final facility = entry.value;
                  return _ScaleFacilityCard(
                    facility: facility,
                    delay: index * 150,
                    controller: _facilitiesController,
                    isBalanceVisible: _isBalanceVisible,
                    onTap: () => _navigateToFacilities(),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsSection() {
    return AnimatedBuilder(
      animation: _transactionsController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _transactionsController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _transactionsController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Recent Activity'),
                const SizedBox(height: 16),
                _ModernContainer(
                  child: Column(
                    children: _transactions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final transaction = entry.value;
                      return Column(
                        children: [
                          _FadeUpTransactionTile(
                            transaction: transaction,
                            delay: index * 100,
                            controller: _transactionsController,
                            isBalanceVisible: _isBalanceVisible,
                            onTap: () => _showTransactionDetails(transaction),
                          ),
                          if (index < _transactions.length - 1)
                            Divider(
                              color: Colors.white.withOpacity(0.1),
                              height: 1,
                              indent: 64,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 20,
          width: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _primaryColor.withOpacity(0.5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCardIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cards.length, (index) {
        final isActive = _currentCardIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? _primaryColor : Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // Navigation methods
  void _navigateToProfile() {
    Navigator.push(context, _createSlideTransition(const ProfileScreen()));
  }

  void _navigateToAccounts() {
    Navigator.push(context, _createSlideTransition(const AccountsScreen()));
  }

  void _navigateToCards() {
    Navigator.push(context, _createSlideTransition(const CardsScreen()));
  }

  void _navigateToFacilities() {
    Navigator.push(context, _createSlideTransition(const FacilitiesScreen()));
  }

  void _navigateToStatements() {
    Navigator.push(context, _createSlideTransition(const StatementScreen()));
  }

  PageRouteBuilder _createSlideTransition(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) {
        const begin = Offset(1.0, 0.0);
        final tween = Tween(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  void _showTransactionDetails(TransactionData transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }
}

// Data models (keeping existing structure for compatibility)
class AccountSummary {
  const AccountSummary({
    required this.name,
    required this.accountNumber,
    required this.balance,
    required this.type,
    required this.icon,
    this.isActive = true,
    this.color,
  });

  final String name;
  final String accountNumber;
  final String balance;
  final String type;
  final IconData icon;
  final bool isActive;
  final Color? color;
}

class CardSummary {
  const CardSummary({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cardType,
    required this.limit,
    required this.spent,
    required this.background,
  });

  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cardType;
  final String limit;
  final String spent;
  final String background;
}

class FacilitySummary {
  const FacilitySummary({
    required this.name,
    required this.amount,
    required this.emi,
    required this.nextDue,
    required this.icon,
    required this.status,
  });

  final String name;
  final String amount;
  final String emi;
  final String nextDue;
  final IconData icon;
  final String status;
}

class QuickActionData {
  const QuickActionData(this.icon, this.label, {this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

class TransactionData {
  const TransactionData({
    required this.name,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.reference,
    required this.category,
    required this.description,
    this.icon,
  });

  final String name;
  final String date;
  final String amount;
  final bool isIncome;
  final String reference;
  final String category;
  final String description;
  final IconData? icon;

  Color get iconColor => isIncome ? Colors.green : Colors.red;
  IconData get iconData =>
      icon ?? (isIncome ? Icons.arrow_upward : Icons.arrow_downward);
}

// Modern UI Components with Unique Animations
class _ModernContainer extends StatelessWidget {
  const _ModernContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF545877).withOpacity(0.8),
            const Color(0xFF545877).withOpacity(0.4),
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ModernCreditCard extends StatelessWidget {
  const _ModernCreditCard({
    required this.cardData,
    required this.index,
    required this.isBalanceVisible,
    required this.onTap,
  });

  final CardSummary cardData;
  final int index;
  final bool isBalanceVisible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'creditCard$index',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF545877),
                Color(0xFF2C2E40),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      cardData.background,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Card content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cardData.cardType,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFEB).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: Color(0xFF00FFEB),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isBalanceVisible
                            ? cardData.cardNumber
                            : '**** **** **** ****',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCardInfo('HOLDER', cardData.cardHolder),
                          _buildCardInfo('EXPIRES', cardData.expiryDate),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSpendingInfo(
                            'Spent',
                            isBalanceVisible
                                ? 'LKR ${cardData.spent}'
                                : 'LKR •••••',
                          ),
                          _buildSpendingInfo(
                            'Limit',
                            isBalanceVisible
                                ? 'LKR ${cardData.limit}'
                                : 'LKR •••••',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00FFEB),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StaggeredAccountCard extends StatelessWidget {
  const _StaggeredAccountCard({
    required this.account,
    required this.delay,
    required this.controller,
    required this.isBalanceVisible,
    required this.onTap,
  });

  final AccountSummary account;
  final int delay;
  final AnimationController controller;
  final bool isBalanceVisible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        (delay / 1000.0).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutCubic,
      ),
    ));

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-50 * (1 - delayedAnimation.value), 0),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _ModernContainer(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            account.icon,
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
                                account.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${account.type} • ${account.accountNumber}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isBalanceVisible
                                  ? 'LKR ${account.balance}'
                                  : 'LKR •••••••',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScaleFacilityCard extends StatelessWidget {
  const _ScaleFacilityCard({
    required this.facility,
    required this.delay,
    required this.controller,
    required this.isBalanceVisible,
    required this.onTap,
  });

  final FacilitySummary facility;
  final int delay;
  final AnimationController controller;
  final bool isBalanceVisible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        (delay / 1000.0).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutBack,
      ),
    ));

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * delayedAnimation.value),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _ModernContainer(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Row(
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                facility.icon,
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
                                    facility.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Outstanding: ${isBalanceVisible ? "LKR ${facility.amount}" : "LKR •••••••"}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'EMI',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  isBalanceVisible
                                      ? 'LKR ${facility.emi}'
                                      : 'LKR •••••',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00FFEB),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Next Due: ${facility.nextDue}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  facility.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FadeUpTransactionTile extends StatelessWidget {
  const _FadeUpTransactionTile({
    required this.transaction,
    required this.delay,
    required this.controller,
    required this.isBalanceVisible,
    required this.onTap,
  });

  final TransactionData transaction;
  final int delay;
  final AnimationController controller;
  final bool isBalanceVisible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        (delay / 1000.0).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutCubic,
      ),
    ));

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - delayedAnimation.value)),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            transaction.iconColor.withOpacity(0.2),
                            transaction.iconColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        transaction.iconData,
                        color: transaction.iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isBalanceVisible
                              ? transaction.amount
                              : (transaction.isIncome
                                  ? '+LKR •••••'
                                  : '-LKR •••••'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: transaction.iconColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Success',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
}

class _TransactionDetailsSheet extends StatelessWidget {
  const _TransactionDetailsSheet({required this.transaction});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0027),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent(controller, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF545877), Color(0xFF2C2E40)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00FFEB),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  transaction.iconColor.withOpacity(0.2),
                  transaction.iconColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.iconData,
              color: transaction.iconColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transaction.amount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: transaction.iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transaction.name,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScrollController controller, BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF545877).withOpacity(0.3),
                const Color(0xFF545877).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildDetailRow('Date & Time', transaction.date),
              _buildDetailRow('Category', transaction.category),
              _buildDetailRow(
                  'Type', transaction.isIncome ? 'Credit' : 'Debit'),
              _buildDetailRow('Reference', transaction.reference),
              _buildDetailRow('Description', transaction.description),
              _buildDetailRow('Status', 'Completed'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFEB),
              foregroundColor: const Color(0xFF0F0027),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
