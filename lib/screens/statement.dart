import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;

  bool _showAppBarTitle = false;
  String _selectedFilter = 'All';
  String _selectedSort = 'Latest';

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);

  // Filter and sort options
  static const List<String> _filters = ['All', 'Income', 'Expense'];
  static const List<String> _sortOptions = [
    'Latest',
    'Oldest',
    'Highest',
    'Lowest'
  ];

  // Tab configuration
  static const List<TabConfig> _tabConfigs = [
    TabConfig('Last 7 days', 7, 'This Week'),
    TabConfig('Last 30 days', 30, 'This Month'),
    TabConfig('Last 3 months', 90, 'Last 3 Months'),
  ];

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _tabController = TabController(length: _tabConfigs.length, vsync: this);
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final shouldShow = _scrollController.offset > 120;
    if (shouldShow != _showAppBarTitle) {
      setState(() => _showAppBarTitle = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _showAppBarTitle
          ? _backgroundColor.withOpacity(0.95)
          : Colors.transparent,
      elevation: _showAppBarTitle ? 2 : 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: _primaryColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: const Text(
          'Account Statement',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: _primaryColor),
          onPressed: () => _showFilterSheet(context),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(child: _buildHeaderSection()),
        SliverToBoxAdapter(child: _buildTabBar()),
      ],
      body: TabBarView(
        controller: _tabController,
        children: _tabConfigs
            .map(
              (config) => _TransactionList(
                days: config.days,
                selectedFilter: _selectedFilter,
                selectedSort: _selectedSort,
                periodText: config.periodText,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_backgroundColor, Color.fromARGB(255, 84, 88, 119)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Statement',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Savings Account • xxxx-xxxx-1001',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 25),
          const _FinancialSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: _primaryColor,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: _tabConfigs.map((config) => Tab(text: config.label)).toList(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showExportOptionsDialog(context),
      backgroundColor: _primaryColor,
      icon: const Icon(Icons.file_download_outlined, color: _backgroundColor),
      label: const Text('Export Statement',
          style: TextStyle(color: _backgroundColor)),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  // Modal methods
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        selectedFilter: _selectedFilter,
        selectedSort: _selectedSort,
        onFiltersChanged: (filter, sort) {
          setState(() {
            _selectedFilter = filter;
            _selectedSort = sort;
          });
        },
      ),
    );
  }

  void _showExportOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ExportDialog(
        onExportSuccess: (format) => _showExportSuccess(context, format),
      ),
    );
  }

  void _showExportSuccess(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Statement exported as $format successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

// Data models
class TabConfig {
  const TabConfig(this.label, this.days, this.periodText);
  final String label;
  final int days;
  final String periodText;
}

class TransactionData {
  const TransactionData({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.icon,
  });

  final int id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final IconData icon;

  Color get amountColor => isIncome ? Colors.green : Colors.red;
  String get formattedAmount =>
      '${isIncome ? '+' : '-'}LKR ${amount.toStringAsFixed(0)}';
}

// Reusable components
class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard();

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: _FinancialSummaryItem(
              title: 'Income',
              amount: 'LKR 14,000',
              icon: Icons.arrow_upward,
              color: Colors.green,
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const Expanded(
            child: _FinancialSummaryItem(
              title: 'Expense',
              amount: 'LKR 7,000',
              icon: Icons.arrow_downward,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummaryItem extends StatelessWidget {
  const _FinancialSummaryItem({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.days,
    required this.selectedFilter,
    required this.selectedSort,
    required this.periodText,
  });

  final int days;
  final String selectedFilter;
  final String selectedSort;
  final String periodText;

  @override
  Widget build(BuildContext context) {
    final transactions = _getFilteredAndSortedTransactions();

    return transactions.isEmpty
        ? const _EmptyState()
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: transactions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _DateGroupHeader(
                  periodText: periodText,
                  selectedFilter: selectedFilter,
                );
              }
              return _TransactionCard(transaction: transactions[index - 1]);
            },
          );
  }

  List<TransactionData> _getFilteredAndSortedTransactions() {
    var transactions = _generateTransactions(days);

    // Apply filter
    if (selectedFilter != 'All') {
      transactions = transactions
          .where((t) =>
              (selectedFilter == 'Income' && t.isIncome) ||
              (selectedFilter == 'Expense' && !t.isIncome))
          .toList();
    }

    // Apply sort
    switch (selectedSort) {
      case 'Latest':
        transactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        transactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest':
        transactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest':
        transactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return transactions;
  }

  List<TransactionData> _generateTransactions(int days) {
    final now = DateTime.now();
    final random = Random();
    final List<TransactionData> transactions = [];

    final incomeTypes = [
      ('Salary', Icons.attach_money),
      ('Freelance', Icons.work),
      ('Investment', Icons.trending_up),
    ];

    final expenseTypes = [
      ('Groceries', Icons.shopping_cart),
      ('Transport', Icons.directions_bus),
      ('Utilities', Icons.electrical_services),
      ('Entertainment', Icons.movie),
    ];

    for (int i = 0; i < 20; i++) {
      final date = now.subtract(Duration(days: random.nextInt(days)));
      final isIncome = random.nextBool();
      final types = isIncome ? incomeTypes : expenseTypes;
      final selectedType = types[random.nextInt(types.length)];

      transactions.add(TransactionData(
        id: i + 1,
        title: selectedType.$1,
        category: isIncome ? 'Income' : 'Expense',
        amount: (random.nextInt(5000) + 1000).toDouble(),
        date: date,
        isIncome: isIncome,
        icon: selectedType.$2,
      ));
    }

    return transactions;
  }
}

class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({
    required this.periodText,
    required this.selectedFilter,
  });

  final String periodText;
  final String selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            periodText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  selectedFilter,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down,
                    color: Color(0xFF00FFEB), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(context, transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: transaction.amountColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.amountColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.category,
                        style: TextStyle(
                          fontSize: 13,
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
                      transaction.formattedAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: transaction.amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
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
  }

  void _showTransactionDetails(
      BuildContext context, TransactionData transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0027),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailsModal(transaction: transaction),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.selectedFilter,
    required this.selectedSort,
    required this.onFiltersChanged,
  });

  final String selectedFilter;
  final String selectedSort;
  final Function(String filter, String sort) onFiltersChanged;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _currentFilter;
  late String _currentSort;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.selectedFilter;
    _currentSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildFilterSection(),
          const SizedBox(height: 20),
          _buildSortSection(),
          const SizedBox(height: 30),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filter & Sort',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFEB),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        _buildFilterChips(),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        _buildSortChips(),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 10,
      children: ['All', 'Income', 'Expense'].map((filter) {
        final isSelected = _currentFilter == filter;
        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          selectedColor: const Color(0xFF00FFEB),
          backgroundColor:
              const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF0F0027) : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            if (selected) setState(() => _currentFilter = filter);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSortChips() {
    return Wrap(
      spacing: 10,
      children: ['Latest', 'Oldest', 'Highest', 'Lowest'].map((option) {
        final isSelected = _currentSort == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: const Color(0xFF00FFEB),
          backgroundColor:
              const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF0F0027) : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            if (selected) setState(() => _currentSort = option);
          },
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.onFiltersChanged(_currentFilter, _currentSort);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FFEB),
          foregroundColor: const Color(0xFF0F0027),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Apply Filters',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ExportDialog extends StatelessWidget {
  const _ExportDialog({required this.onExportSuccess});

  final Function(String format) onExportSuccess;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F0027),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Statement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FFEB),
              ),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              context,
              icon: Icons.picture_as_pdf,
              title: 'PDF Document',
              subtitle: 'Detailed statement',
              format: 'PDF',
            ),
            const Divider(color: Colors.white24),
            _buildExportOption(
              context,
              icon: Icons.table_chart,
              title: 'Excel Spreadsheet',
              subtitle: 'Export as XLS',
              format: 'Excel',
            ),
            const Divider(color: Colors.white24),
            _buildExportOption(
              context,
              icon: Icons.text_snippet,
              title: 'CSV File',
              subtitle: 'Compatible with most financial software',
              format: 'CSV',
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String format,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FFEB)),
      title: Text(
        title,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.6)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context);
        onExportSuccess(format);
      },
    );
  }
}

class _TransactionDetailsModal extends StatelessWidget {
  const _TransactionDetailsModal({required this.transaction});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          _buildHandle(),
          const SizedBox(height: 24),
          _buildTransactionIcon(),
          const SizedBox(height: 16),
          _buildTransactionTitle(),
          const SizedBox(height: 8),
          _buildTransactionAmount(),
          const SizedBox(height: 4),
          _buildTransactionDate(formatter),
          const SizedBox(height: 32),
          _buildTransactionDetails(),
          const Spacer(),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTransactionIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: transaction.amountColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        transaction.icon,
        color: transaction.amountColor,
        size: 32,
      ),
    );
  }

  Widget _buildTransactionTitle() {
    return Text(
      transaction.title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTransactionAmount() {
    return Text(
      transaction.formattedAmount,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: transaction.amountColor,
      ),
    );
  }

  Widget _buildTransactionDate(DateFormat formatter) {
    return Text(
      formatter.format(transaction.date),
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Column(
      children: [
        _TransactionDetailItem(
          title: 'Category',
          value: transaction.category,
          icon: Icons.category,
        ),
        _TransactionDetailItem(
          title: 'Transaction ID',
          value: 'TRX${transaction.id.toString().padLeft(6, '0')}',
          icon: Icons.receipt,
        ),
        _TransactionDetailItem(
          title: 'Status',
          value: 'Completed',
          icon: Icons.check_circle,
          valueColor: Colors.green,
        ),
        _TransactionDetailItem(
          title: 'Payment Method',
          value: 'Savings Account',
          icon: Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFEB),
              foregroundColor: const Color(0xFF0F0027),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionDetailItem extends StatelessWidget {
  const _TransactionDetailItem({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
