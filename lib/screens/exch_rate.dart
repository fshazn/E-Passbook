import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExchangeRatesContent extends StatefulWidget {
  const ExchangeRatesContent({super.key});

  @override
  State<ExchangeRatesContent> createState() => _ExchangeRatesContentState();
}

class _ExchangeRatesContentState extends State<ExchangeRatesContent>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  // Search and filter functionality
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fromAmountController = TextEditingController();
  String _searchQuery = '';
  List<BankExchangeRateData> _filteredRates = [];
  List<BankExchangeRateData> _allRates = [];
  String _selectedBaseCurrency = 'LKR';
  String _selectedTargetCurrency = 'USD';
  bool _isLoading = false;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // Mock API response data structure matching your bank's API
  static const List<Map<String, dynamic>> _mockApiResponse = [
    {
      "B_RATE": 324.50,
      "S_RATE": 330.25,
      "M_RATE": 327.38,
      "CURR_CODE": 1.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "USD"
    },
    {
      "B_RATE": 350.75,
      "S_RATE": 356.90,
      "M_RATE": 353.83,
      "CURR_CODE": 2.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "EUR"
    },
    {
      "B_RATE": 410.30,
      "S_RATE": 417.85,
      "M_RATE": 414.08,
      "CURR_CODE": 3.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "GBP"
    },
    {
      "B_RATE": 2.18,
      "S_RATE": 2.25,
      "M_RATE": 2.22,
      "CURR_CODE": 4.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "JPY"
    },
    {
      "B_RATE": 215.60,
      "S_RATE": 220.40,
      "M_RATE": 218.00,
      "CURR_CODE": 5.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "AUD"
    },
    {
      "B_RATE": 238.90,
      "S_RATE": 244.15,
      "M_RATE": 241.53,
      "CURR_CODE": 6.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "CAD"
    },
    {
      "B_RATE": 241.20,
      "S_RATE": 246.80,
      "M_RATE": 244.00,
      "CURR_CODE": 7.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "SGD"
    },
    {
      "B_RATE": 3.89,
      "S_RATE": 3.95,
      "M_RATE": 3.92,
      "CURR_CODE": 8.0,
      "DATE_RATE": "2025-06-09T00:00:00",
      "LATEST_TIME": "15:14:26",
      "ENG_DESC": "INR"
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExchangeRates();
    _searchController.addListener(_onSearchChanged);
    _fromAmountController.text = '1000';
  }

  void _setupAnimations() {
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _loadExchangeRates() {
    setState(() => _isLoading = true);

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      // Convert API response to our data model
      _allRates = _mockApiResponse.map((rateData) {
        return BankExchangeRateData.fromApiResponse(rateData);
      }).toList();

      setState(() {
        _filteredRates = List.from(_allRates);
        _isLoading = false;
      });
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterRates();
    });
  }

  void _filterRates() {
    if (_searchQuery.isEmpty) {
      _filteredRates = List.from(_allRates);
    } else {
      _filteredRates = _allRates.where((rate) {
        return rate.currencyCode
                .toString()
                .toLowerCase()
                .contains(_searchQuery) ||
            rate.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _fromAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildRatesSummary(),
                          const SizedBox(height: 24),
                          _buildCurrencyConverter(),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                              'Today\'s Exchange Rates', _filteredRates.length),
                          const SizedBox(height: 16),
                          _buildExchangeRatesList(),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank Exchange Rates',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Current Rates',
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
                  icon: Icons.refresh,
                  onPressed: () => _refreshRates(),
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.info_outline,
                  onPressed: () => _showRateInfo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading exchange rates...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesSummary() {
    if (_allRates.isEmpty) return const SizedBox.shrink();

    final latestUpdate =
        _allRates.isNotEmpty ? _allRates.first.latestTime : 'N/A';
    final rateDate = _allRates.isNotEmpty ? _allRates.first.dateRate : '';

    return _AnimatedContainer(
      animation: _animationController,
      offset: 40,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.update,
                  color: _primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rate Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BANK RATES',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoMetric(
                    label: 'Last Updated',
                    value: latestUpdate,
                    icon: Icons.access_time,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoMetric(
                    label: 'Rate Date',
                    value: _formatDate(rateDate),
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoMetric(
                    label: 'Available Currencies',
                    value: '${_allRates.length}',
                    icon: Icons.language,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoMetric(
                    label: 'Rate Type',
                    value: 'Official Bank',
                    icon: Icons.account_balance,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    return _AnimatedContainer(
      animation: _animationController,
      offset: 60,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.currency_exchange,
                  color: _primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Currency Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _CurrencyConverterCard(
              fromCurrency: _selectedBaseCurrency,
              toCurrency: _selectedTargetCurrency,
              fromAmountController: _fromAmountController,
              rates: _allRates,
              onSwap: () => setState(() {
                final temp = _selectedBaseCurrency;
                _selectedBaseCurrency = _selectedTargetCurrency;
                _selectedTargetCurrency = temp;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return _AnimatedContainer(
      animation: _animationController,
      offset: 80,
      child: Row(
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
              '$count Currencies',
              style: const TextStyle(
                fontSize: 12,
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRatesList() {
    return _AnimatedContainer(
      animation: _animationController,
      offset: 100,
      child: Column(
        children: _filteredRates
            .map((rate) => _BankRateCard(
                  rate: rate,
                  onTap: () => _showRateDetails(rate),
                ))
            .toList(),
      ),
    );
  }

  // Helper methods
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Today';
    }
  }

  // Action methods
  void _refreshRates() {
    HapticFeedback.lightImpact();
    _loadExchangeRates();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exchange rates refreshed'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSearchBottomSheet() {
    _showBottomSheet(
      title: 'Search Currencies',
      child: _buildSearchContent(),
    );
  }

  void _showRateInfo() {
    _showBottomSheet(
      title: 'Rate Information',
      child: _buildRateInfoContent(),
    );
  }

  void _showRateDetails(BankExchangeRateData rate) {
    _showBottomSheet(
      title:
          '${_getCurrencyFlag(rate.description)} ${rate.description} Details',
      child: _buildRateDetailsContent(rate),
    );
  }

  void _showBottomSheet({
    required String title,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContainer(
        title: title,
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
                    hintText: 'Search currencies...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () => _searchController.clear(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_searchQuery.isEmpty)
          const Text(
            'Search for specific currencies (USD, EUR, etc.)',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          )
        else
          Text(
            'Found ${_filteredRates.length} result(s)',
            style: const TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildRateInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          title: 'Buying Rate (B_RATE)',
          description: 'Rate at which the bank buys foreign currency from you',
          icon: Icons.arrow_downward,
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Selling Rate (S_RATE)',
          description: 'Rate at which the bank sells foreign currency to you',
          icon: Icons.arrow_upward,
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Mid Rate (M_RATE)',
          description: 'Average of buying and selling rates for reference',
          icon: Icons.balance,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: _primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Important Note',
                    style: TextStyle(
                      color: Color(0xFF00FFEB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'These are official bank rates and may differ from market rates. Rates are updated regularly during banking hours.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRateDetailsContent(BankExchangeRateData rate) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _RateDetailCard(rate: rate),
          const SizedBox(height: 20),
          _buildRateComparison(rate),
          const SizedBox(height: 20),
          _buildRateActions(rate),
        ],
      ),
    );
  }

  Widget _buildRateComparison(BankExchangeRateData rate) {
    final spread = rate.sellingRate - rate.buyingRate;
    final spreadPercentage = (spread / rate.midRate) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow('Currency Code', rate.description),
          _DetailRow('Rate Spread', '${spread.toStringAsFixed(2)} LKR'),
          _DetailRow('Spread %', '${spreadPercentage.toStringAsFixed(2)}%'),
          _DetailRow('Last Updated', rate.latestTime),
          _DetailRow('Rate Date', _formatDate(rate.dateRate)),
        ],
      ),
    );
  }

  Widget _buildRateActions(BankExchangeRateData rate) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedTargetCurrency = rate.description;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: _backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.calculate),
            label: const Text('Use in Calculator',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _setRateAlert(rate),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _primaryColor),
              foregroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.notifications_active),
            label: const Text('Set Rate Alert',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _setRateAlert(BankExchangeRateData rate) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rate alert set for ${rate.description}'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getCurrencyFlag(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'JPY':
        return '🇯🇵';
      case 'AUD':
        return '🇦🇺';
      case 'CAD':
        return '🇨🇦';
      case 'SGD':
        return '🇸🇬';
      case 'INR':
        return '🇮🇳';
      case 'CHF':
        return '🇨🇭';
      case 'CNY':
        return '🇨🇳';
      default:
        return '💱';
    }
  }
}

// Data model matching your API structure
class BankExchangeRateData {
  const BankExchangeRateData({
    required this.buyingRate,
    required this.sellingRate,
    required this.midRate,
    required this.currencyCode,
    required this.dateRate,
    required this.latestTime,
    required this.description,
  });

  final double buyingRate; // B_RATE
  final double sellingRate; // S_RATE
  final double midRate; // M_RATE
  final double currencyCode; // CURR_CODE
  final String dateRate; // DATE_RATE
  final String latestTime; // LATEST_TIME
  final String description; // ENG_DESC

  factory BankExchangeRateData.fromApiResponse(Map<String, dynamic> json) {
    return BankExchangeRateData(
      buyingRate: (json['B_RATE'] as num).toDouble(),
      sellingRate: (json['S_RATE'] as num).toDouble(),
      midRate: (json['M_RATE'] as num).toDouble(),
      currencyCode: (json['CURR_CODE'] as num).toDouble(),
      dateRate: json['DATE_RATE'] as String,
      latestTime: json['LATEST_TIME'] as String,
      description: json['ENG_DESC'] as String,
    );
  }
}

// Component widgets
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

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00FFEB), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
      ),
    );
  }
}

class _CurrencyConverterCard extends StatelessWidget {
  const _CurrencyConverterCard({
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmountController,
    required this.rates,
    required this.onSwap,
  });

  final String fromCurrency;
  final String toCurrency;
  final TextEditingController fromAmountController;
  final List<BankExchangeRateData> rates;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    // Find the target currency rate
    BankExchangeRateData? targetRate;
    try {
      targetRate = rates.firstWhere(
        (rate) => rate.description.toUpperCase() == toCurrency.toUpperCase(),
      );
    } catch (e) {
      targetRate = null;
    }

    final double fromAmount = double.tryParse(fromAmountController.text) ?? 0;
    double toAmount = 0;
    double rate = 0;

    if (targetRate != null) {
      if (fromCurrency == 'LKR' && toCurrency != 'LKR') {
        // Converting from LKR to foreign currency (use buying rate)
        rate = 1 / targetRate.buyingRate;
        toAmount = fromAmount * rate;
      } else if (fromCurrency != 'LKR' && toCurrency == 'LKR') {
        // Converting from foreign currency to LKR (use selling rate)
        rate = targetRate.sellingRate;
        toAmount = fromAmount * rate;
      } else {
        // Same currency or unsupported conversion
        toAmount = fromAmount;
        rate = 1;
      }
    }

    return Column(
      children: [
        // From Currency
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFEB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fromCurrency,
                  style: const TextStyle(
                    color: Color(0xFF00FFEB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: fromAmountController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Swap Button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: GestureDetector(
            onTap: onSwap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFEB).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.swap_vert,
                color: Color(0xFF00FFEB),
                size: 24,
              ),
            ),
          ),
        ),

        // To Currency
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  toCurrency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  toAmount.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        if (targetRate != null)
          Text(
            fromCurrency == 'LKR'
                ? '1 $fromCurrency = ${rate.toStringAsFixed(5)} $toCurrency (Bank Buying Rate)'
                : '1 $fromCurrency = ${rate.toStringAsFixed(2)} $toCurrency (Bank Selling Rate)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          )
        else
          const Text(
            'Rate not available for selected currency',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _BankRateCard extends StatelessWidget {
  const _BankRateCard({
    required this.rate,
    required this.onTap,
  });

  final BankExchangeRateData rate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFlag = _getCurrencyFlag(rate.description);
    final spread = rate.sellingRate - rate.buyingRate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.8),
            const Color.fromARGB(255, 84, 88, 119).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FFEB).withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Currency Info
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FFEB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          currencyFlag,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                rate.description,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF00FFEB).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Code: ${rate.currencyCode.toInt()}',
                                  style: const TextStyle(
                                    color: Color(0xFF00FFEB),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Updated at ${rate.latestTime}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rates Display
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Buy: ${rate.buyingRate.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Sell: ${rate.sellingRate.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mid: ${rate.midRate.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF00FFEB),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Rate Details Bar
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_flat,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Spread: ${spread.toStringAsFixed(2)} LKR',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OFFICIAL',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
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
    );
  }

  String _getCurrencyFlag(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'JPY':
        return '🇯🇵';
      case 'AUD':
        return '🇦🇺';
      case 'CAD':
        return '🇨🇦';
      case 'SGD':
        return '🇸🇬';
      case 'INR':
        return '🇮🇳';
      case 'CHF':
        return '🇨🇭';
      case 'CNY':
        return '🇨🇳';
      default:
        return '💱';
    }
  }
}

class _RateDetailCard extends StatelessWidget {
  const _RateDetailCard({required this.rate});

  final BankExchangeRateData rate;

  @override
  Widget build(BuildContext context) {
    final currencyFlag = _getCurrencyFlag(rate.description);

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
        border: Border.all(color: const Color(0xFF00FFEB).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFEB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    currencyFlag,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rate.description}/LKR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Currency Code: ${rate.currencyCode.toInt()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BANK RATE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _RateInfoTile(
                  label: 'Buying Rate',
                  value: 'LKR ${rate.buyingRate.toStringAsFixed(2)}',
                  subtitle: 'Bank buys from you',
                  valueColor: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RateInfoTile(
                  label: 'Selling Rate',
                  value: 'LKR ${rate.sellingRate.toStringAsFixed(2)}',
                  subtitle: 'Bank sells to you',
                  valueColor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RateInfoTile(
                  label: 'Mid Rate',
                  value: 'LKR ${rate.midRate.toStringAsFixed(2)}',
                  subtitle: 'Reference rate',
                  valueColor: const Color(0xFF00FFEB),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RateInfoTile(
                  label: 'Spread',
                  value:
                      'LKR ${(rate.sellingRate - rate.buyingRate).toStringAsFixed(2)}',
                  subtitle: 'Rate difference',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrencyFlag(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'JPY':
        return '🇯🇵';
      case 'AUD':
        return '🇦🇺';
      case 'CAD':
        return '🇨🇦';
      case 'SGD':
        return '🇸🇬';
      case 'INR':
        return '🇮🇳';
      case 'CHF':
        return '🇨🇭';
      case 'CNY':
        return '🇨🇳';
      default:
        return '💱';
    }
  }
}

class _RateInfoTile extends StatelessWidget {
  const _RateInfoTile({
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
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
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0027),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -1),
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
      child: Row(
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
      ),
    );
  }
}
