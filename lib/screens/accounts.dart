import 'package:e_pass_app/screens/addAccounts.dart';
import 'package:e_pass_app/screens/statement.dart';
import 'package:flutter/material.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 800);
  static const Duration _transitionDuration = Duration(milliseconds: 500);

  // Account data
  static const List<AccountData> _accounts = [
    AccountData(
      title: 'Current Account',
      accountNumber: '0115700231001',
      balance: 'LKR 130.00',
      icon: Icons.account_balance,
      type: AccountType.current,
    ),
    AccountData(
      title: 'Savings Account',
      accountNumber: '0115700231001',
      balance: 'LKR 11,500.00',
      icon: Icons.savings,
      type: AccountType.savings,
    ),
  ];

  static const List<AccountData> _investments = [
    AccountData(
      title: 'Term Investment',
      accountNumber: '0115700231001',
      balance: 'LKR 11,500.00',
      icon: Icons.account_balance_wallet,
      type: AccountType.investment,
      maturityDate: '23/12/2024',
    ),
  ];

  static const List<QuickActionData> _quickActions = [
    QuickActionData(Icons.add_circle_outline, 'Add'),
    QuickActionData(Icons.history, 'History'),
    QuickActionData(Icons.more_horiz, 'More'),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildAnimatedTotalBalance(),
              const SizedBox(height: 24),
              _buildSectionHeader('Your Accounts'),
              _buildAnimatedAccountsList(_accounts),
              const SizedBox(height: 24),
              _buildSectionHeader('Term Investments'),
              _buildAnimatedAccountsList(_investments),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'My Accounts',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: _primaryColor),
          onPressed: () {
            // Search functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: _primaryColor),
          onPressed: () {
            // Notifications functionality
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedTotalBalance() {
    return _AnimatedContainer(
      animation: _animationController,
      offset: 30,
      child: _GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'LKR 11,630.00',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _quickActions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return _QuickActionButton(
          icon: action.icon,
          label: action.label,
          onTap: () => _handleQuickAction(index),
        );
      }).toList(),
    );
  }

  void _handleQuickAction(int index) {
    switch (index) {
      case 0: // Add
        _navigateToAddAccount();
        break;
      case 1: // History
        _navigateToStatement();
        break;
      case 2: // More
        _showMoreDetailsBottomSheet();
        break;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _primaryColor,
      ),
    );
  }

  Widget _buildAnimatedAccountsList(List<AccountData> accounts) {
    return _AnimatedContainer(
      animation: _animationController,
      offset: 40,
      child: Column(
        children: [
          const SizedBox(height: 5),
          ...accounts.map((account) => _AccountCard(
                account: account,
                onTap: () => _showAccountDetails(account),
                onStatementTap: () => _navigateToStatement(),
              )),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddAccount,
      backgroundColor: _primaryColor,
      icon: const Icon(Icons.add, color: _backgroundColor),
      label:
          const Text('Add Account', style: TextStyle(color: _backgroundColor)),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  // Navigation methods
  void _navigateToAddAccount() {
    Navigator.push(
        context,
        _createSlideTransition(
          const AddAccountsScreen(),
          const Offset(0.0, 1.0),
        ));
  }

  void _navigateToStatement() {
    Navigator.push(
        context,
        _createSlideTransition(
          const StatementScreen(),
          const Offset(1.0, 0.0),
        ));
  }

  PageRouteBuilder _createSlideTransition(Widget child, Offset begin) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) {
        final tween = Tween(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: _transitionDuration,
    );
  }

  // Bottom sheet methods
  void _showMoreDetailsBottomSheet() {
    _showBottomSheet(
      title: 'Account Summary',
      child: _buildSummaryContent(),
    );
  }

  void _showAccountDetails(AccountData account) {
    _showBottomSheet(
      title: 'Account Details',
      showCloseButton: true,
      child: _buildAccountDetailsContent(account),
    );
  }

  void _showBottomSheet({
    required String title,
    required Widget child,
    bool showCloseButton = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContainer(
        title: title,
        showCloseButton: showCloseButton,
        child: child,
      ),
    );
  }

  Widget _buildSummaryContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: const [
        _SummaryItem(
          title: 'Total Accounts',
          value: '3',
          icon: Icons.account_circle_outlined,
        ),
        _SummaryItem(
          title: 'Total Balance',
          value: 'LKR 11,630.00',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _SummaryItem(
          title: 'Last Transaction',
          value: 'March 18, 2025',
          icon: Icons.history,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAccountDetailsContent(AccountData account) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _AccountDetailCard(account: account),
        const SizedBox(height: 25),
        _buildDetailsList(account),
        const SizedBox(height: 20),
        _buildStatementButton(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDetailsList(AccountData account) {
    return Column(
      children: [
        _DetailItem(label: 'Account Type', value: account.title),
        _DetailItem(label: 'Branch', value: 'Main Branch, Colombo'),
        _DetailItem(label: 'Date Opened', value: 'January 15, 2023'),
        _DetailItem(label: 'Last Transaction', value: 'March 18, 2025'),
        _DetailItem(label: 'Account Status', value: 'Active'),
      ],
    );
  }

  Widget _buildStatementButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        _navigateToStatement();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long),
          SizedBox(width: 10),
          Text('View Statement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

// Data models
enum AccountType { current, savings, investment }

class AccountData {
  const AccountData({
    required this.title,
    required this.accountNumber,
    required this.balance,
    required this.icon,
    required this.type,
    this.maturityDate,
  });

  final String title;
  final String accountNumber;
  final String balance;
  final IconData icon;
  final AccountType type;
  final String? maturityDate;

  String get maskedAccountNumber =>
      'xxxx-xxxx-${accountNumber.substring(accountNumber.length - 4)}';
}

class QuickActionData {
  const QuickActionData(this.icon, this.label);
  final IconData icon;
  final String label;
}

// Reusable components
class _AnimatedContainer extends StatelessWidget {
  const _AnimatedContainer({
    required this.animation,
    required this.offset,
    required this.child,
  });

  final AnimationController animation;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Transform.translate(
        offset: Offset(0, (1 - animation.value) * offset),
        child: Opacity(opacity: animation.value, child: child),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.onTap,
    required this.onStatementTap,
  });

  final AccountData account;
  final VoidCallback onTap;
  final VoidCallback onStatementTap;

  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAccountHeader(),
                const Divider(height: 24, thickness: 1, color: Colors.white24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(account.icon, color: _primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  account.maskedAccountNumber,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                if (account.maturityDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Matures on ${account.maturityDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              account.balance,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Available',
              style: TextStyle(fontSize: 12, color: Colors.green[400]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          label: 'View Statement',
          icon: Icons.receipt_long,
          onTap: onStatementTap,
        ),
        _ActionButton(
          label: 'Details',
          icon: Icons.info_outline,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00FFEB)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContainer extends StatelessWidget {
  const _BottomSheetContainer({
    required this.title,
    required this.child,
    this.showCloseButton = false,
  });

  final String title;
  final Widget child;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0027),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: child,
            ),
          ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: showCloseButton
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FFEB),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          : Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FFEB),
              ),
            ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFEB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00FFEB), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 14),
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

class _AccountDetailCard extends StatelessWidget {
  const _AccountDetailCard({required this.account});

  final AccountData account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            account.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            account.accountNumber,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Available Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            account.balance,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
