import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'accounts.dart';
import 'cards.dart';
import 'facilities.dart';
import 'profile.dart';
import 'statement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;
  late final PageController _cardPageController;

  int _currentCardIndex = 0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color(0xFF545877);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // Card data as Maps to maintain compatibility with CardsScreen
  static const List<Map<String, dynamic>> _cardsList = [
    {
      'cardNumber': '**** **** **** 2345',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '02/30',
      'background': 'assets/images/debitcard1.png',
    },
    {
      'cardNumber': '**** **** **** 7890',
      'cardHolder': 'F. S. Ismail',
      'expiryDate': '05/28',
      'background': 'assets/images/prestigecard1.png',
    },
  ];

  // Transaction data
  static const List<TransactionData> _transactions = [
    TransactionData(
      name: 'Salary Payment',
      date: 'March 5, 2025',
      amount: '+7,000',
      isIncome: true,
      reference: 'SAL25032025',
      category: 'Salary',
      description: 'Monthly Salary',
    ),
    TransactionData(
      name: 'Shopping Purchase',
      date: 'March 3, 2025',
      amount: '-3,000',
      isIncome: false,
      reference: 'PUR03032025',
      category: 'Shopping',
      description: 'Shopping at Mall',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupPageController();
  }

  void _setupAnimations() {
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _setupPageController() {
    _cardPageController = PageController(viewportFraction: 0.98);
    _cardPageController.addListener(_onPageChanged);
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
    _animationController.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildSummaryCards(),
                const SizedBox(height: 16),
                _buildCardsCarousel(),
                _buildCardIndicators(),
                const SizedBox(height: 24),
                _buildSectionHeader('Recent Transactions'),
                const SizedBox(height: 16),
                _buildTransactionsList(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _backgroundColor,
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF545877), Color(0xFF2C2E40)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildGreetingSection(),
              _buildProfileButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Good Morning',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        Text(
          'Hi, Fathima Shazna',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () => _navigateToProfile(),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _primaryColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey[800],
          radius: 22,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return _GlassContainer(
      child: Row(
        children: [
          Expanded(
              child: _buildSummaryItem('Income last week', '+23,400',
                  Icons.arrow_upward, Colors.green)),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          Expanded(
              child: _buildSummaryItem('Expense last week', '-3,000',
                  Icons.arrow_downward, Colors.red)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, String amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                      color: color, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsCarousel() {
    return SizedBox(
      height: 225,
      child: PageView.builder(
        controller: _cardPageController,
        itemCount: _cardsList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _CreditCard(
            cardData: _cardsList[index],
            index: index,
            onTap: () => _navigateToCards(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCardIndicators() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_cardsList.length, (index) {
          final isActive = _currentCardIndex == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 20 : 8,
            decoration: BoxDecoration(
              color: isActive ? _primaryColor : Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
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
            color: _primaryColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return _GlassContainer(
      child: Column(
        children: [
          ...List.generate(4, (index) {
            final transaction = _transactions[index % _transactions.length];
            return Column(
              children: [
                _TransactionTile(
                  transaction: transaction,
                  onTap: () => _showTransactionDetails(transaction),
                ),
                if (index < 3)
                  Divider(
                    color: Colors.white.withOpacity(0.1),
                    height: 1,
                    indent: 72,
                    endIndent: 16,
                  ),
              ],
            );
          }),
          _buildViewAllButton(),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => _navigateToStatements(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View All Transactions',
                style: TextStyle(
                    color: _primaryColor, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, color: _primaryColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToProfile() {
    Navigator.push(context, _createSlideTransition(const ProfileScreen()));
  }

  void _navigateToCards(int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => CardsScreen(
          initialCardIndex: index,
          cardsList: _cardsList, // Directly pass the Map list
        ),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
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
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
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

// Data models
class TransactionData {
  const TransactionData({
    required this.name,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.reference,
    required this.category,
    required this.description,
  });

  final String name;
  final String date;
  final String amount;
  final bool isIncome;
  final String reference;
  final String category;
  final String description;

  Color get iconColor => isIncome ? Colors.green : Colors.red;
  IconData get iconData => isIncome ? Icons.arrow_upward : Icons.arrow_downward;
}

// Reusable components
class _GlassContainer extends StatelessWidget {
  const _GlassContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF545877).withOpacity(0.8),
            const Color(0xFF545877).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.cardData,
    required this.index,
    required this.onTap,
  });

  final Map<String, dynamic> cardData;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'creditCard$index',
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 15,
        shadowColor: Colors.black.withOpacity(0.5),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 225,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Image.asset(
                      cardData['background'],
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  _buildCardContent(),
                ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 93),
          Text(
            cardData['cardNumber'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 2,
              fontFamily: 'Courier Prime',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 20),
              _buildCardInfo('CARD HOLDER', cardData['cardHolder']),
              const SizedBox(width: 40),
              _buildCardInfo('EXPIRES', cardData['expiryDate']),
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
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.onTap,
  });

  final TransactionData transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: transaction.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(transaction.iconData,
                    color: transaction.iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.date,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.amount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.iconColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailsSheet extends StatelessWidget {
  const _TransactionDetailsSheet({required this.transaction});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0027),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildSheetHeader(),
            Expanded(child: _buildSheetContent(controller, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF545877), Color(0xFF2C2E40)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: transaction.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(transaction.iconData,
                    color: transaction.iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.amount,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: transaction.iconColor,
                    ),
                  ),
                  Text(
                    transaction.isIncome ? 'Income' : 'Expense',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheetContent(ScrollController controller, BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        _buildDetailItem('Date', transaction.date),
        _buildDetailItem(
            'Transaction Type', transaction.isIncome ? 'Income' : 'Expense'),
        _buildDetailItem('Category', transaction.category),
        _buildDetailItem('Description', transaction.description),
        _buildDetailItem('Status', 'Completed'),
        _buildDetailItem('Reference', transaction.reference),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFEB),
            foregroundColor: const Color(0xFF0F0027),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
