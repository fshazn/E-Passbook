import 'package:flutter/material.dart';
import 'statement.dart';

class CardsScreen extends StatefulWidget {
  final int initialCardIndex;
  final List<Map<String, dynamic>>? cardsList;

  const CardsScreen({
    super.key,
    this.initialCardIndex = 0,
    this.cardsList,
  });

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final PageController _pageController;
  late final List<Map<String, dynamic>> _cards; // Keep as Map for compatibility

  int _currentPage = 0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // Default card data
  static const List<Map<String, dynamic>> _defaultCards = [
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
      viewportFraction: 0.98,
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
    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(),
          _buildSectionHeader('Your Cards'),
          _buildCardsCarousel(),
          _buildCardIndicators(),
          _buildCardActions(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Your Cards',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: _primaryColor),
          onPressed: _showAddCardModal,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: _primaryColor),
          onPressed: () {
            // More options
          },
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: _GlassContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Available',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'LKR 35,250.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _QuickActionButton(
              icon: Icons.history,
              label: 'History',
              onTap: _navigateToStatement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardsCarousel() {
    return SizedBox(
      height: 225,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _cards.length,
        onPageChanged: (int page) {
          setState(() => _currentPage = page);
        },
        itemBuilder: (context, index) => _CreditCard(
          cardData: _cards[index],
          index: index,
          onTap: () => _showCardDetails(index),
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
        children: List.generate(_cards.length, (index) {
          final isActive = _currentPage == index;
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

  Widget _buildCardActions() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Card Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                icon: Icons.receipt_long,
                label: 'View Transactions',
                onTap: _navigateToStatement,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToStatement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatementScreen()),
    );
  }

  // Modal methods
  void _showCardDetails(int index) {
    _showModal(
      title: 'Card Details',
      height: 0.75,
      child: _buildCardDetailsContent(_cards[index]),
    );
  }

  void _showAddCardModal() {
    _showModal(
      title: 'Add New Card',
      height: 0.6,
      child: _buildAddCardContent(),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _DetailItem(
          icon: Icons.account_balance,
          title: 'Card Type',
          value: 'Visa Debit Card',
        ),
        _DetailItem(
          icon: Icons.person_outline,
          title: 'Card Holder',
          value: card['cardHolder'] ?? '',
        ),
        _DetailItem(
          icon: Icons.credit_card,
          title: 'Card Number',
          value: card['cardNumber'] ?? '',
        ),
        _DetailItem(
          icon: Icons.calendar_today,
          title: 'Expiry Date',
          value: card['expiryDate'] ?? '',
        ),
        _DetailItem(
          icon: Icons.security,
          title: 'CVV',
          value: '***',
        ),
        _DetailItem(
          icon: Icons.attach_money,
          title: 'Available Balance',
          value: 'LKR 25,500.00',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: _ActionButton(
            icon: Icons.receipt_long,
            label: 'Transactions',
            onTap: () {
              Navigator.pop(context);
              _navigateToStatement();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _TextField(
            label: 'Card Number',
            hint: '0000 0000 0000 0000',
            keyboardType: TextInputType.number,
          ),
          const Row(
            children: [
              Expanded(
                child: _TextField(
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _TextField(
                  label: 'CVV',
                  hint: '000',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const _TextField(
            label: 'Card Holder Name',
            hint: 'Enter your name as on card',
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: _backgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Card',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          colors: [
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.8),
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        cardData['background'] ?? '',
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
            cardData['cardNumber'] ?? '',
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
              _buildCardInfo('CARD HOLDER', cardData['cardHolder'] ?? ''),
              const SizedBox(width: 40),
              _buildCardInfo('EXPIRES', cardData['expiryDate'] ?? ''),
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
        backgroundColor: const Color(0xFF00FFEB).withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00FFEB), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor:
                  const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00FFEB)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
