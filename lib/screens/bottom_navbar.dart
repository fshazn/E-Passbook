import 'package:e_pass_app/screens/accounts.dart';
import 'package:e_pass_app/screens/cards.dart';
import 'package:e_pass_app/screens/exch_rate.dart';
import 'package:e_pass_app/screens/facilities.dart';
import 'package:e_pass_app/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);

  // Navigation data - Added Exchange Rates tab
  static const List<TabData> _tabsData = [
    TabData(Icons.account_balance_rounded, 'Accounts'),
    TabData(Icons.credit_card_rounded, 'Cards'),
    TabData(Icons.business_rounded, 'Facilities'),
    TabData(Icons.currency_exchange_rounded, 'Exchange'), // New tab
    TabData(Icons.person_rounded, 'Profile'),
  ];

  // Page widgets
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _setupTabController();
    _setupPages();
  }

  void _setupTabController() {
    _tabController = TabController(length: _tabsData.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _setupPages() {
    _pages = const [
      AccountsContent(),
      CardsContent(),
      FacilitiesContent(),
      ExchangeRatesContent(), // Add the exchange rates screen
      ProfileContent(),
    ];
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() => _selectedIndex = _tabController.index);
      // Add haptic feedback for better UX
      HapticFeedback.lightImpact();
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
          physics:
              const NeverScrollableScrollPhysics(), // Disable swipe to prevent accidental navigation
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

// Data model
class TabData {
  const TabData(this.icon, this.label);
  final IconData icon;
  final String label;
}
