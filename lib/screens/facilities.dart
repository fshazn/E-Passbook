import 'package:flutter/material.dart';
import 'dart:ui';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentPage = 0;

  // Animation controller for subtle animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // List of facilities to display
  final List<Map<String, dynamic>> _facilities = [
    {
      'title': 'Home Finance',
      'icon': Icons.home,
      'settlementDate': '12/03/2025',
      'capitalAmount': '500,000',
      'settlementAmount': '450,000',
      'color': Color(0xFF0F0027),
    },
    {
      'title': 'Vehicle Finance',
      'icon': Icons.directions_car,
      'settlementDate': '25/04/2025',
      'capitalAmount': '300,000',
      'settlementAmount': '275,000',
      'color': Color(0xFF0F0027),
    },
    {
      'title': 'Staff Finance',
      'icon': Icons.account_balance_wallet,
      'settlementDate': '10/05/2025',
      'capitalAmount': '150,000',
      'settlementAmount': '135,000',
      'color': Color(0xFF0F0027),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Facilities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00FFEB),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: const Color(0xFF00FFEB)),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: const Color(0xFF00FFEB)),
            onPressed: () {
              // Notifications functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Facility Cards - PageView
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_fadeAnimation),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _facilities.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildFacilityCard(index);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Page Indicator
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _facilities.length,
                    (index) => _buildPageIndicator(index),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions Row
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFacilityCard(int index) {
    final facility = _facilities[index];

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
        }

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.9, end: 1.0),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, double val, child) {
            return Transform.scale(
              scale: value * val,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => _showFacilityDetails(facility),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 84, 88, 119).withOpacity(0.9),
                    const Color.fromARGB(255, 84, 88, 119).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon and title
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            facility['icon'],
                            color: const Color(0xFF00FFEB),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          facility['title'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: const Color(0xFF00FFEB),
                          size: 16,
                        ),
                      ],
                    ),
                  ),

                  // Content with facility details
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          label: 'Settlement Date',
                          value: facility['settlementDate'],
                          icon: Icons.calendar_today,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          label: 'Capital Amount',
                          value: 'LKR ${facility['capitalAmount']}',
                          icon: Icons.account_balance,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          label: 'Settlement Amount',
                          value: 'LKR ${facility['settlementAmount']}',
                          icon: Icons.money,
                        ),
                        const SizedBox(height: 25),
                        _buildActionButton(facility['title']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00FFEB),
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String facilityType) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00FFEB).withOpacity(0.8),
              const Color(0xFF00FFEB).withOpacity(0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFEB).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'View ${facilityType} Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F0027),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    bool isActive = _currentPage == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: isActive ? 12 : 8,
      width: isActive ? 30 : 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isActive ? 6 : 4),
        color: isActive ? const Color(0xFF00FFEB) : Colors.grey.shade600,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF00FFEB).withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }

  // Updated method to use _showAddLoanModal instead of _showQuickActionFeedback
  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> quickActions = [
      {'icon': Icons.add_circle_outline, 'label': 'New Loan'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          quickActions.length,
          (index) => _buildQuickActionItem(
            icon: quickActions[index]['icon'],
            label: quickActions[index]['label'],
            onTap: () {
              // Call the new method instead of _showQuickActionFeedback
              _showAddLoanModal();
            },
          ),
        ),
      ),
    );
  }

  // Updated method with proper onTap handling
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00FFEB),
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final bottomNavItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.dashboard, 'label': 'Services'},
      {'icon': Icons.analytics, 'label': 'Activity'},
      {'icon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF00FFEB),
                  width: 3,
                ),
              ),
            ),
            labelColor: const Color(0xFF00FFEB),
            unselectedLabelColor: Colors.grey,
            tabs: List.generate(
              bottomNavItems.length,
              (index) => Tab(
                icon: Icon(
                  bottomNavItems[index]['icon'] as IconData,
                  size: 24,
                ),
                text: bottomNavItems[index]['label'] as String,
                iconMargin: EdgeInsets.only(bottom: 4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00FFEB),
          size: 20,
        ),
      ),
    );
  }

  // FIXED: Removed duplicate title in the scrollable content
  void _showFacilityDetails(Map<String, dynamic> facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0027),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: <Widget>[
              // Handle indicator
              Container(
                margin: EdgeInsets.only(top: 12),
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // Header with facility title and close button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            facility['icon'],
                            color: const Color(0xFF00FFEB),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          facility['title'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Facility Details Section
                      Text(
                        'Facility Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00FFEB),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Details Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 84, 88, 119)
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Account Number', '9876-5432-1098'),
                            Divider(
                                height: 24,
                                color: Colors.white.withOpacity(0.2)),
                            _buildDetailRow(
                                'Settlement Date', facility['settlementDate']),
                            Divider(
                                height: 24,
                                color: Colors.white.withOpacity(0.2)),
                            _buildDetailRow('Capital Amount',
                                'LKR ${facility['capitalAmount']}'),
                            Divider(
                                height: 24,
                                color: Colors.white.withOpacity(0.2)),
                            _buildDetailRow('Settlement Amount',
                                'LKR ${facility['settlementAmount']}'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Payment History
                      Text(
                        'Recent Payments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00FFEB),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Payment history list
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 84, 88, 119)
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPaymentHistoryItem(
                                'Feb 10, 2025', 'LKR 15,000'),
                            Divider(
                                height: 20,
                                color: Colors.white.withOpacity(0.2)),
                            _buildPaymentHistoryItem(
                                'Jan 10, 2025', 'LKR 15,000'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(String date, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: const Color(0xFF00FFEB),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonSmall({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF00FFEB) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? Colors.transparent : const Color(0xFF00FFEB),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF00FFEB).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? const Color(0xFF0F0027)
                    : const Color(0xFF00FFEB),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? const Color(0xFF0F0027)
                      : const Color(0xFF00FFEB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method for Add New Loan functionality
  void _showAddLoanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateModal) {
          // This is needed for dropdowns to work properly in modal
          String selectedLoanType = 'Home Finance';
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0027),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Handle indicator at top of modal
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),

                // Modal header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Apply for New Loan',
                        style: TextStyle(
                          color: const Color(0xFF00FFEB),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Section
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                        ),
                        _buildTextField(
                          label: 'National ID',
                          hint: 'Enter your ID number',
                        ),
                        _buildTextField(
                          label: 'Contact Number',
                          hint: 'Enter your mobile number',
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 24),

                        // Loan Details Section
                        Text(
                          'Loan Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Loan Type Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Loan Type',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 84, 88, 119)
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedLoanType,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1A1F47),
                                  style: TextStyle(color: Colors.white),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.white),
                                  items: [
                                    'Home Finance',
                                    'Vehicle Finance',
                                    'Staff Finance',
                                    'Personal Loan',
                                    'Business Loan',
                                  ].map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setStateModal(() {
                                        selectedLoanType = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Loan Amount (LKR)',
                          hint: 'Enter amount',
                          keyboardType: TextInputType.number,
                        ),

                        // Loan Term with Unit
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                label: 'Loan Term',
                                hint: 'Duration',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unit',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 84, 88, 119)
                                              .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: 'Years',
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1A1F47),
                                        style: TextStyle(color: Colors.white),
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: Colors.white),
                                        items: [
                                          'Months',
                                          'Years',
                                        ].map((String unit) {
                                          return DropdownMenuItem<String>(
                                            value: unit,
                                            child: Text(unit),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          // Handle unit change
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        _buildTextField(
                          label: 'Purpose of Loan',
                          hint: 'Briefly describe why you need this loan',
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        // Income Information
                        Text(
                          'Income Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Monthly Income (LKR)',
                          hint: 'Enter your monthly income',
                          keyboardType: TextInputType.number,
                        ),

                        _buildTextField(
                          label: 'Employer',
                          hint: 'Enter your employer name',
                        ),

                        // Employment Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Employment Status',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 84, 88, 119)
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: 'Full-time',
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1A1F47),
                                  style: TextStyle(color: Colors.white),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.white),
                                  items: [
                                    'Full-time',
                                    'Part-time',
                                    'Self-employed',
                                    'Contract',
                                    'Other',
                                  ].map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    // Handle employment status change
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle loan application submission
                              Navigator.pop(context);
                              _showFeedbackSnackBar(
                                  'Loan application submitted successfully');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FFEB),
                              foregroundColor: const Color(0xFF0F0027),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Submit Application',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // Helper method for text fields
  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor:
                  const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: const Color(0xFF00FFEB), width: 1),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionFeedback(String action) {
    _showFeedbackSnackBar('$action feature coming soon');
  }

  void _showFeedbackSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color(0xFF0F0027),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: const Color(0xFF00FFEB),
          onPressed: () {},
        ),
      ),
    );
  }
}
