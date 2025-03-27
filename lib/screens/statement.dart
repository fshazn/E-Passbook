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
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  String _selectedFilter = 'All';
  String _selectedSort = 'Latest';
  final List<String> _filters = ['All', 'Income', 'Expense'];
  final List<String> _sortOptions = ['Latest', 'Oldest', 'Highest', 'Lowest'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 120 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 120 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0027),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showAppBarTitle
            ? const Color(0xFF0F0027).withOpacity(0.95)
            : Colors.transparent,
        elevation: _showAppBarTitle ? 2 : 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00FFEB)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AnimatedOpacity(
          opacity: _showAppBarTitle ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: const Text(
            'Account Statement',
            style: TextStyle(
              color: Color(0xFF00FFEB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF00FFEB)),
            onPressed: () {
              _showFilterSheet(context);
            },
          ),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildHeaderSection(),
            ),
            SliverToBoxAdapter(
              child: _buildTabBar(),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTransactionList(7),
            _buildTransactionList(30),
            _buildTransactionList(90),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showExportOptionsDialog(context);
        },
        backgroundColor: const Color(0xFF00FFEB),
        icon:
            Icon(Icons.file_download_outlined, color: const Color(0xFF0F0027)),
        label: Text('Export Statement',
            style: TextStyle(color: const Color(0xFF0F0027))),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F0027),
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.9),
          ],
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
              color: Color(0xFF00FFEB),
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
          Container(
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFinancialSummary(
                      title: 'Income',
                      amount: 'LKR 14,000',
                      icon: Icons.arrow_upward,
                      color: Colors.green,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildFinancialSummary(
                      title: 'Expense',
                      amount: 'LKR 7,000',
                      icon: Icons.arrow_downward,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
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
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF00FFEB).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: const Color(0xFF00FFEB),
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(text: 'Last 7 days'),
          Tab(text: 'Last 30 days'),
          Tab(text: 'Last 3 months'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(int days) {
    // Filter transactions based on selected options
    List<Map<String, dynamic>> transactions = _generateTransactions(days);

    if (_selectedFilter != 'All') {
      transactions = transactions
          .where((transaction) =>
              (_selectedFilter == 'Income' && transaction['isIncome']) ||
              (_selectedFilter == 'Expense' && !transaction['isIncome']))
          .toList();
    }

    // Sort transactions
    switch (_selectedSort) {
      case 'Latest':
        transactions.sort((a, b) => b['date'].compareTo(a['date']));
        break;
      case 'Oldest':
        transactions.sort((a, b) => a['date'].compareTo(b['date']));
        break;
      case 'Highest':
        transactions.sort((a, b) => b['amount'].compareTo(a['amount']));
        break;
      case 'Lowest':
        transactions.sort((a, b) => a['amount'].compareTo(b['amount']));
        break;
    }

    return transactions.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: transactions.length + 1, // +1 for date groups
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildDateGroup(days);
              }

              final transaction = transactions[index - 1];
              return _buildTransactionCard(transaction);
            },
          );
  }

  Widget _buildDateGroup(int days) {
    String periodText;
    switch (days) {
      case 7:
        periodText = 'This Week';
        break;
      case 30:
        periodText = 'This Month';
        break;
      case 90:
        periodText = 'Last 3 Months';
        break;
      default:
        periodText = 'All Transactions';
    }

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
                  _selectedFilter,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF00FFEB),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isIncome = transaction['isIncome'];
    final formatter = DateFormat('MMM dd, yyyy');
    final formattedDate = formatter.format(transaction['date']);

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
          onTap: () {
            _showTransactionDetails(context, transaction);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction['icon'],
                    color: isIncome ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction['category'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount and date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isIncome
                          ? '+LKR ${transaction['amount'].toString()}'
                          : '-LKR ${transaction['amount'].toString()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
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

  Widget _buildEmptyState() {
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

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F0027),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Search Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FFEB),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by description or amount',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF00FFEB)),
                  filled: true,
                  fillColor:
                      const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFEB),
                      foregroundColor: const Color(0xFF0F0027),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0027),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              ),
              const SizedBox(height: 20),
              const Text(
                'Transaction Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildFilterChips(setState),
              const SizedBox(height: 20),
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildSortChips(setState),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      this.setState(() {});
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFEB),
                    foregroundColor: const Color(0xFF0F0027),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(StateSetter setState) {
    return Wrap(
      spacing: 10,
      children: _filters.map((filter) {
        final isSelected = _selectedFilter == filter;
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
            if (selected) {
              setState(() {
                _selectedFilter = filter;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildSortChips(StateSetter setState) {
    return Wrap(
      spacing: 10,
      children: _sortOptions.map((option) {
        final isSelected = _selectedSort == option;
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
            if (selected) {
              setState(() {
                _selectedSort = option;
              });
            }
          },
        );
      }).toList(),
    );
  }

  void _showExportOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F0027),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                icon: Icons.picture_as_pdf,
                title: 'PDF Document',
                subtitle: 'Detailed statement',
                onTap: () {
                  Navigator.pop(context);
                  _showExportSuccess(context, 'PDF');
                },
              ),
              const Divider(color: Colors.white24),
              _buildExportOption(
                icon: Icons.table_chart,
                title: 'Excel Spreadsheet',
                subtitle: 'Export as XLS ',
                onTap: () {
                  Navigator.pop(context);
                  _showExportSuccess(context, 'Excel');
                },
              ),
              const Divider(color: Colors.white24),
              _buildExportOption(
                icon: Icons.text_snippet,
                title: 'CSV File',
                subtitle: 'Compatible with most financial software',
                onTap: () {
                  Navigator.pop(context);
                  _showExportSuccess(context, 'CSV');
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
      onTap: onTap,
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

  void _showTransactionDetails(
      BuildContext context, Map<String, dynamic> transaction) {
    final isIncome = transaction['isIncome'];
    final formatter = DateFormat('MMMM dd, yyyy');
    final formattedDate = formatter.format(transaction['date']);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0027),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isIncome
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                transaction['icon'],
                color: isIncome ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              transaction['title'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isIncome
                  ? '+LKR ${transaction['amount'].toString()}'
                  : '-LKR ${transaction['amount'].toString()}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            _buildTransactionDetailItem(
              title: 'Category',
              value: transaction['category'],
              icon: Icons.category,
            ),
            _buildTransactionDetailItem(
              title: 'Transaction ID',
              value: 'TRX${transaction['id'].toString().padLeft(6, '0')}',
              icon: Icons.receipt,
            ),
            _buildTransactionDetailItem(
              title: 'Status',
              value: 'Completed',
              icon: Icons.check_circle,
              valueColor: Colors.green,
            ),
            _buildTransactionDetailItem(
              title: 'Payment Method',
              value: 'Savings Account',
              icon: Icons.account_balance,
            ),
            const Spacer(),
            Row(
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetailItem({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
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

  List<Map<String, dynamic>> _generateTransactions(int days) {
    final now = DateTime.now();
    final random = Random();
    final List<Map<String, dynamic>> transactions = [];

    for (int i = 0; i < 20; i++) {
      final date = now.subtract(Duration(days: random.nextInt(days)));
      final isIncome = random.nextBool();
      transactions.add({
        'id': i + 1,
        'title': isIncome ? 'Salary' : 'Groceries',
        'category': isIncome ? 'Income' : 'Expense',
        'amount': random.nextInt(5000) + 1000,
        'date': date,
        'isIncome': isIncome,
        'icon': isIncome ? Icons.attach_money : Icons.shopping_cart,
      });
    }

    return transactions;
  }
}
