import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'statement.dart';

class AccountsContent extends StatefulWidget {
  const AccountsContent({super.key});

  @override
  State<AccountsContent> createState() => _AccountsContentState();
}

class _AccountsContentState extends State<AccountsContent>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<AccountData> _filteredAccounts = [];
  List<AccountData> _filteredInvestments = [];

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // Account data
  static const List<AccountData> _accounts = [
    AccountData(
      title: 'Current Account',
      accountNumber: '0115700231001',
      balance: 'LKR 130.00',
      icon: Icons.account_balance,
      type: AccountType.current,
      lastTransaction: 'Mar 18, 2025',
      status: 'Active',
    ),
    AccountData(
      title: 'Savings Account',
      accountNumber: '0115700231002',
      balance: 'LKR 11,500.00',
      icon: Icons.savings,
      type: AccountType.savings,
      lastTransaction: 'Mar 15, 2025',
      status: 'Active',
    ),
  ];

  static const List<AccountData> _investments = [
    AccountData(
      title: 'Term Investment',
      accountNumber: '0115700231003',
      balance: 'LKR 25,000.00',
      icon: Icons.account_balance_wallet,
      type: AccountType.investment,
      maturityDate: '23/12/2024',
      lastTransaction: 'Jan 15, 2025',
      status: 'Active',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeFilteredLists();
    _searchController.addListener(_onSearchChanged);
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

  void _initializeFilteredLists() {
    _filteredAccounts = List.from(_accounts);
    _filteredInvestments = List.from(_investments);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterAccounts();
    });
  }

  void _filterAccounts() {
    if (_searchQuery.isEmpty) {
      _filteredAccounts = List.from(_accounts);
      _filteredInvestments = List.from(_investments);
    } else {
      _filteredAccounts = _accounts.where((account) {
        return account.title.toLowerCase().contains(_searchQuery) ||
            account.accountNumber.contains(_searchQuery) ||
            account.balance.toLowerCase().contains(_searchQuery) ||
            account.status.toLowerCase().contains(_searchQuery);
      }).toList();

      _filteredInvestments = _investments.where((account) {
        return account.title.toLowerCase().contains(_searchQuery) ||
            account.accountNumber.contains(_searchQuery) ||
            account.balance.toLowerCase().contains(_searchQuery) ||
            account.status.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    if (_filteredAccounts.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Bank Accounts', _filteredAccounts.length),
                      const SizedBox(height: 16),
                      _buildAnimatedAccountsList(_filteredAccounts),
                      const SizedBox(height: 24),
                    ],
                    if (_filteredInvestments.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Investments', _filteredInvestments.length),
                      const SizedBox(height: 16),
                      _buildAnimatedAccountsList(_filteredInvestments),
                      const SizedBox(height: 24),
                    ],
                    if (_filteredAccounts.isEmpty &&
                        _filteredInvestments.isEmpty &&
                        _searchQuery.isNotEmpty) ...[
                      _buildNoResultsWidget(),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return _AnimatedContainer(
      animation: _animationController,
      offset: 20,
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
                        'Hi! Shazna',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'My Accounts',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.search,
                      onPressed: () => _showSearchBottomSheet(),
                    ),
                    const SizedBox(width: 8),
                    _HeaderIconButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () => _showNotifications(),
                      showBadge: true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                height: 20,
                width: 4,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            '$count ${count == 1 ? 'Account' : 'Accounts'}',
            style: const TextStyle(
              fontSize: 12,
              color: _primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedAccountsList(List<AccountData> accounts) {
    return _AnimatedContainer(
      animation: _animationController,
      offset: 40,
      child: Column(
        children: accounts
            .map((account) => _EnhancedAccountCard(
                  account: account,
                  onTap: () => _showAccountDetails(account),
                  onStatementTap: () => _navigateToStatement(),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No accounts found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
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

  // Bottom sheet methods
  void _showSearchBottomSheet() {
    _showBottomSheet(
      title: 'Search Accounts',
      child: _buildSearchContent(),
    );
  }

  void _showNotifications() {
    _showBottomSheet(
      title: 'Notifications',
      child: _buildNotificationsContent(),
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

  Widget _buildSearchContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _containerColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search accounts...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // Search is handled by the listener
                  },
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_searchQuery.isEmpty) ...[
          const Text(
            'Start typing to search through your accounts',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'You can search by:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildSearchHint('Account name (Current, Savings, etc.)'),
          _buildSearchHint('Account number'),
          _buildSearchHint('Balance amount'),
          _buildSearchHint('Account status'),
        ] else ...[
          Text(
            'Found ${_filteredAccounts.length + _filteredInvestments.length} result(s)',
            style: const TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (_filteredAccounts.isEmpty && _filteredInvestments.isEmpty)
            const Text(
              'No accounts match your search',
              style: TextStyle(color: Colors.white70),
            ),
        ],
      ],
    );
  }

  Widget _buildSearchHint(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hint,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return const Column(
      children: [
        _NotificationItem(
          title: 'Account Statement Ready',
          message: 'Your March statement is now available',
          time: '2 hours ago',
          icon: Icons.receipt_long,
        ),
        _NotificationItem(
          title: 'Investment Matured',
          message: 'Your term investment has matured',
          time: '1 day ago',
          icon: Icons.check_circle,
        ),
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
        _buildActionButtons(),
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
        _DetailItem(label: 'Last Transaction', value: account.lastTransaction),
        _DetailItem(label: 'Account Status', value: account.status),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _navigateToStatement();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.receipt_long),
        label: const Text('View Statement',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
    required this.lastTransaction,
    required this.status,
    this.maturityDate,
  });

  final String title;
  final String accountNumber;
  final String balance;
  final IconData icon;
  final AccountType type;
  final String lastTransaction;
  final String status;
  final String? maturityDate;

  String get maskedAccountNumber =>
      'xxxx-xxxx-${accountNumber.substring(accountNumber.length - 4)}';
}

// Enhanced components
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

class _EnhancedAccountCard extends StatelessWidget {
  const _EnhancedAccountCard({
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _containerColor.withOpacity(0.8),
            _containerColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildAccountHeader(),
                const SizedBox(height: 16),
                _buildAccountInfo(),
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
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primaryColor.withOpacity(0.2),
                _primaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
          ),
          child: Icon(account.icon, color: _primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                account.maskedAccountNumber,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              account.balance,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                account.status,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.access_time,
            label: 'Last Activity',
            value: account.lastTransaction,
          ),
        ),
        if (account.maturityDate != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _InfoChip(
              icon: Icons.schedule,
              label: 'Matures',
              value: account.maturityDate!,
              valueColor: Colors.orange,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Statement',
            icon: Icons.receipt_long,
            onTap: onStatementTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Details',
            icon: Icons.info_outline,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00FFEB)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
      height: MediaQuery.of(context).size.height * 0.7,
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FFEB),
                    ),
                    overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.6),
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00FFEB).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFEB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(account.icon,
                    color: const Color(0xFF00FFEB), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.accountNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Available Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            account.balance,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.only(bottom: 16),
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
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
