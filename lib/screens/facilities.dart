import 'package:flutter/material.dart';
import 'dart:ui';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  int _currentPage = 0;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color.fromARGB(255, 84, 88, 119);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // Facilities data
  static const List<FacilityData> _facilities = [
    FacilityData(
      title: 'Home Finance',
      icon: Icons.home,
      settlementDate: '12/03/2025',
      capitalAmount: '500,000',
      settlementAmount: '450,000',
    ),
    FacilityData(
      title: 'Vehicle Finance',
      icon: Icons.directions_car,
      settlementDate: '25/04/2025',
      capitalAmount: '300,000',
      settlementAmount: '275,000',
    ),
    FacilityData(
      title: 'Staff Finance',
      icon: Icons.account_balance_wallet,
      settlementDate: '10/05/2025',
      capitalAmount: '150,000',
      settlementAmount: '135,000',
    ),
  ];

  static const List<TabItemData> _bottomNavItems = [
    TabItemData(Icons.home, 'Home'),
    TabItemData(Icons.dashboard, 'Services'),
    TabItemData(Icons.analytics, 'Activity'),
    TabItemData(Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _tabController = TabController(length: _bottomNavItems.length, vsync: this);
    _pageController = PageController(viewportFraction: 0.9);
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
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
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildFacilitiesCarousel(),
            const SizedBox(height: 20),
            _buildPageIndicators(),
            const SizedBox(height: 30),
            _buildQuickActions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Your Facilities',
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

  Widget _buildFacilitiesCarousel() {
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_fadeAnimation),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _facilities.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _FacilityCard(
              facility: _facilities[index],
              pageController: _pageController,
              index: index,
              onTap: () => _showFacilityDetails(_facilities[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _facilities.length,
          (index) => _PageIndicator(
            isActive: _currentPage == index,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _GlassContainer(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'New Loan',
            onTap: _showAddLoanModal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: TabBar(
            controller: _tabController,
            indicator: const BoxDecoration(
              border: Border(top: BorderSide(color: _primaryColor, width: 3)),
            ),
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: _bottomNavItems
                .map((item) => Tab(
                      icon: Icon(item.icon, size: 24),
                      text: item.label,
                      iconMargin: const EdgeInsets.only(bottom: 4),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  // Modal methods
  void _showFacilityDetails(FacilityData facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FacilityDetailsModal(facility: facility),
    );
  }

  void _showAddLoanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddLoanModal(),
    );
  }

  void _showFeedbackSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _backgroundColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: _primaryColor,
          onPressed: () {},
        ),
      ),
    );
  }
}

// Data models
class FacilityData {
  const FacilityData({
    required this.title,
    required this.icon,
    required this.settlementDate,
    required this.capitalAmount,
    required this.settlementAmount,
  });

  final String title;
  final IconData icon;
  final String settlementDate;
  final String capitalAmount;
  final String settlementAmount;
}

class TabItemData {
  const TabItemData(this.icon, this.label);
  final IconData icon;
  final String label;
}

// Reusable components
class _GlassContainer extends StatelessWidget {
  const _GlassContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF00FFEB), size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.pageController,
    required this.index,
    required this.onTap,
  });

  final FacilityData facility;
  final PageController pageController;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double value = 1.0;
        if (pageController.position.haveDimensions) {
          value = pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) => Transform.scale(
            scale: value * val,
            child: child,
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
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
                  _buildHeader(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                Icon(facility.icon, color: const Color(0xFF00FFEB), size: 26),
          ),
          const SizedBox(width: 15),
          Text(
            facility.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF00FFEB),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          _InfoRow(
            label: 'Settlement Date',
            value: facility.settlementDate,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Capital Amount',
            value: 'LKR ${facility.capitalAmount}',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Settlement Amount',
            value: 'LKR ${facility.settlementAmount}',
            icon: Icons.money,
          ),
          const SizedBox(height: 25),
          _ActionButton(facilityTitle: facility.title),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00FFEB), size: 20),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 4),
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.facilityTitle});

  final String facilityTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'View $facilityTitle Details',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0027),
          ),
        ),
      ),
    );
  }
}

class _FacilityDetailsModal extends StatelessWidget {
  const _FacilityDetailsModal({required this.facility});

  final FacilityData facility;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0027),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 5,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(facility.icon,
                    color: const Color(0xFF00FFEB), size: 26),
              ),
              const SizedBox(width: 15),
              Text(
                facility.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Facility Details'),
          const SizedBox(height: 15),
          _DetailsCard(facility: facility),
          const SizedBox(height: 25),
          const _SectionHeader(title: 'Recent Payments'),
          const SizedBox(height: 15),
          const _PaymentHistoryCard(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00FFEB),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.facility});

  final FacilityData facility;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Account Number', '9876-5432-1098'),
          _buildDivider(),
          _buildDetailRow('Settlement Date', facility.settlementDate),
          _buildDivider(),
          _buildDetailRow('Capital Amount', 'LKR ${facility.capitalAmount}'),
          _buildDivider(),
          _buildDetailRow(
              'Settlement Amount', 'LKR ${facility.settlementAmount}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 24, color: Colors.white.withOpacity(0.2));
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Column(
        children: [
          _PaymentHistoryItem(date: 'Feb 10, 2025', amount: 'LKR 15,000'),
          Divider(height: 20, color: Colors.white24),
          _PaymentHistoryItem(date: 'Jan 10, 2025', amount: 'LKR 15,000'),
        ],
      ),
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  const _PaymentHistoryItem({
    required this.date,
    required this.amount,
  });

  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF00FFEB),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(date,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AddLoanModal extends StatefulWidget {
  const _AddLoanModal();

  @override
  State<_AddLoanModal> createState() => _AddLoanModalState();
}

class _AddLoanModalState extends State<_AddLoanModal> {
  String _selectedLoanType = 'Home Finance';
  String _selectedUnit = 'Years';
  String _selectedEmploymentStatus = 'Full-time';

  static const List<String> _loanTypes = [
    'Home Finance',
    'Vehicle Finance',
    'Staff Finance',
    'Personal Loan',
    'Business Loan',
  ];

  static const List<String> _units = ['Months', 'Years'];

  static const List<String> _employmentStatuses = [
    'Full-time',
    'Part-time',
    'Self-employed',
    'Contract',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          _buildHeader(context),
          Expanded(child: _buildForm()),
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
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Apply for New Loan',
            style: TextStyle(
              color: Color(0xFF00FFEB),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoSection(),
          const SizedBox(height: 24),
          _buildLoanDetailsSection(),
          const SizedBox(height: 24),
          _buildIncomeInfoSection(),
          const SizedBox(height: 40),
          _buildSubmitButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormSectionHeader(title: 'Personal Information'),
        const SizedBox(height: 16),
        const _CustomTextField(
            label: 'Full Name', hint: 'Enter your full name'),
        const _CustomTextField(
            label: 'National ID', hint: 'Enter your ID number'),
        const _CustomTextField(
          label: 'Contact Number',
          hint: 'Enter your mobile number',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildLoanDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormSectionHeader(title: 'Loan Details'),
        const SizedBox(height: 16),
        _CustomDropdown(
          label: 'Loan Type',
          value: _selectedLoanType,
          items: _loanTypes,
          onChanged: (value) => setState(() => _selectedLoanType = value!),
        ),
        const SizedBox(height: 16),
        const _CustomTextField(
          label: 'Loan Amount (LKR)',
          hint: 'Enter amount',
          keyboardType: TextInputType.number,
        ),
        Row(
          children: [
            const Expanded(
              flex: 2,
              child: _CustomTextField(
                label: 'Loan Term',
                hint: 'Duration',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomDropdown(
                label: 'Unit',
                value: _selectedUnit,
                items: _units,
                onChanged: (value) => setState(() => _selectedUnit = value!),
              ),
            ),
          ],
        ),
        const _CustomTextField(
          label: 'Purpose of Loan',
          hint: 'Briefly describe why you need this loan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildIncomeInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormSectionHeader(title: 'Income Information'),
        const SizedBox(height: 16),
        const _CustomTextField(
          label: 'Monthly Income (LKR)',
          hint: 'Enter your monthly income',
          keyboardType: TextInputType.number,
        ),
        const _CustomTextField(
          label: 'Employer',
          hint: 'Enter your employer name',
        ),
        _CustomDropdown(
          label: 'Employment Status',
          value: _selectedEmploymentStatus,
          items: _employmentStatuses,
          onChanged: (value) =>
              setState(() => _selectedEmploymentStatus = value!),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Loan application submitted successfully'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFF0F0027),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                textColor: const Color(0xFF00FFEB),
                onPressed: () {},
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FFEB),
          foregroundColor: const Color(0xFF0F0027),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: const Text(
          'Submit Application',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

// Form components
class _FormSectionHeader extends StatelessWidget {
  const _FormSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;

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
            maxLines: maxLines,
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

class _CustomDropdown extends StatelessWidget {
  const _CustomDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 84, 88, 119).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1F47),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
