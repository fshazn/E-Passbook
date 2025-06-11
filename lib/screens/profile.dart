import 'package:e_pass_app/screens/login_banking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

// Import your OTP verification screen to access the session management methods
// import 'package:e_pass_app/screens/otp_verification.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;

  bool _notificationsEnabled = true;
  final bool _darkModeEnabled = true;

  // Theme constants
  static const Color _primaryColor = Color(0xFF00FFEB);
  static const Color _backgroundColor = Color(0xFF0F0027);
  static const Color _containerColor = Color(0xFF545877);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // User data
  static const UserProfile _userProfile = UserProfile(
    name: 'Fathima Shazna',
    email: 'fathima.shazna@example.com',
    phone: '+94 77 123 4567',
    address: '123 Main St, Colombo',
    avatarIcon: Icons.person,
  );

  // Settings configuration
  static const List<SettingSection> _settingSections = [
    SettingSection('Account Settings', [
      SettingItem(
        icon: Icons.person_outline,
        title: 'Personal Information',
        subtitle: 'Update your personal details',
        type: SettingType.navigation,
        action: 'edit_profile',
      ),
      SettingItem(
        icon: Icons.smartphone,
        title: 'Linked Devices',
        subtitle: 'Manage your connected devices',
        type: SettingType.navigation,
        action: 'linked_devices',
      ),
      SettingItem(
        icon: Icons.notifications_outlined,
        title: 'Notification Settings',
        subtitle: 'Customize your notifications',
        type: SettingType.navigation,
        action: 'notification_settings',
      ),
    ]),
    SettingSection('App Settings', [
      SettingItem(
        icon: Icons.notifications_active_outlined,
        title: 'Notifications',
        subtitle: 'Enable or disable notifications',
        type: SettingType.toggle,
        action: 'notifications_toggle',
      ),
      SettingItem(
        icon: Icons.language_outlined,
        title: 'Language',
        subtitle: 'Select your preferred language',
        type: SettingType.selection,
        action: 'language_selection',
        value: 'English',
      ),
    ]),
    SettingSection('Support', [
      SettingItem(
        icon: Icons.help_outline,
        title: 'Help Center',
        subtitle: 'Frequently asked questions',
        type: SettingType.navigation,
        action: 'help_center',
      ),
      SettingItem(
        icon: Icons.headset_mic_outlined,
        title: 'Contact Support',
        subtitle: 'Get help from our team',
        type: SettingType.navigation,
        action: 'contact_support',
      ),
      SettingItem(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'Information about the app',
        type: SettingType.navigation,
        action: 'about',
      ),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Updated logout method with session management
  Future<void> _performLogout() async {
    try {
      // Get stored session info to clear it
      final prefs = await SharedPreferences.getInstance();
      final lastMobile = prefs.getString('last_verified_mobile') ?? '';
      final lastAccount = prefs.getString('last_verified_account') ?? '';

      // Clear the verified session using the same logic from OTP verification
      await _clearVerifiedSession(lastMobile, lastAccount);

      // Navigate back to login screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => const LoginBankingScreen(),
            transitionsBuilder: (context, animation, _, child) {
              const begin = Offset(0.0, 1.0);
              final tween = Tween(begin: begin, end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOut));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false, // Remove all previous routes
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logged out successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error during logout. Please try again.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Clear verified session method (copied from OTP verification logic)
  Future<void> _clearVerifiedSession(String mobileNumber,
      [String? accountNumber]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final account = accountNumber ?? '';
      final sessionKey = '${mobile}_${account}_session'.toLowerCase();

      await prefs.remove('verified_session_$sessionKey');
      await prefs.remove('last_verified_mobile');
      await prefs.remove('last_verified_account');
    } catch (e) {
      debugPrint('Error clearing verified session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _backgroundColor,
      expandedHeight: 240,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: const _ProfileHeader(profile: _userProfile),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: _primaryColor),
          onPressed: _showEditProfileModal,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 12),
          ..._buildSettingSections(),
          const SizedBox(height: 40),
          _buildLogoutButton(),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  List<Widget> _buildSettingSections() {
    final List<Widget> sections = [];

    for (int i = 0; i < _settingSections.length; i++) {
      sections.add(_buildSectionHeader(_settingSections[i].title));
      sections.add(const SizedBox(height: 12));
      sections.add(_SettingsCard(
        section: _settingSections[i],
        notificationsEnabled: _notificationsEnabled,
        onSettingChanged: _handleSettingAction,
      ));
      if (i < _settingSections.length - 1) {
        sections.add(const SizedBox(height: 24));
      }
    }

    return sections;
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

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _primaryColor.withOpacity(0.1),
            _primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutConfirmation,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: _primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Action handlers
  void _handleSettingAction(String action, dynamic value) {
    switch (action) {
      case 'edit_profile':
        _showEditProfileModal();
        break;
      case 'notifications_toggle':
        setState(() => _notificationsEnabled = value as bool);
        break;
      case 'linked_devices':
      case 'notification_settings':
      case 'language_selection':
      case 'help_center':
      case 'contact_support':
      case 'about':
        _showFeatureComingSoon(action);
        break;
    }
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: _backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => _LogoutDialog(
        onConfirm: () {
          Navigator.pop(context);
          _performLogout(); // Updated to use the new logout method
        },
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const LoginBankingScreen(),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(0.0, 1.0);
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileModal(profile: _userProfile),
    );
  }
}

// Updated Logout Dialog with better messaging
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: const Color(0xFF1A1F47),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 10),
              _buildMessage(),
              const SizedBox(height: 30),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF00FFEB).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.logout, color: Color(0xFF00FFEB), size: 30),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Logout',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMessage() {
    return const Text(
      'Are you sure you want to logout? You will need to verify OTP again on your next login.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white70, fontSize: 16),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFEB),
              foregroundColor: const Color(0xFF0F0027),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// Data models (unchanged)
enum SettingType { navigation, toggle, selection }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarIcon,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final IconData avatarIcon;
}

class SettingItem {
  const SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.action,
    this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final SettingType type;
  final String action;
  final String? value;
}

class SettingSection {
  const SettingSection(this.title, this.items);
  final String title;
  final List<SettingItem> items;
}

// All other widget classes remain the same...
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF545877), Color(0xFF2C2E40)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildAvatar(),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00FFEB), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFEB).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: Colors.grey[800],
          child: Icon(profile.avatarIcon, color: Colors.white, size: 60),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.section,
    required this.notificationsEnabled,
    required this.onSettingChanged,
  });

  final SettingSection section;
  final bool notificationsEnabled;
  final Function(String action, dynamic value) onSettingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: section.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildSettingTile(item),
              if (index < section.items.length - 1) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingTile(SettingItem item) {
    switch (item.type) {
      case SettingType.toggle:
        return _SwitchTile(
          item: item,
          value: notificationsEnabled,
          onChanged: (value) => onSettingChanged(item.action, value),
        );
      case SettingType.selection:
        return _SelectionTile(
          item: item,
          onTap: () => onSettingChanged(item.action, null),
        );
      case SettingType.navigation:
      default:
        return _NavigationTile(
          item: item,
          onTap: () => onSettingChanged(item.action, null),
        );
    }
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      height: 1,
      indent: 72,
      endIndent: 16,
    );
  }
}

class _BaseTile extends StatelessWidget {
  const _BaseTile({
    required this.item,
    required this.trailing,
    this.onTap,
  });

  final SettingItem item;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(item.icon, color: const Color(0xFF00FFEB), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.item, required this.onTap});

  final SettingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      item: item,
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white.withOpacity(0.5),
        size: 16,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.item,
    required this.value,
    required this.onChanged,
  });

  final SettingItem item;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      item: item,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00FFEB),
        activeTrackColor: const Color(0xFF00FFEB).withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({required this.item, required this.onTap});

  final SettingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      item: item,
      onTap: onTap,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          item.value ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

class _EditProfileModal extends StatelessWidget {
  const _EditProfileModal({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0027),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildForm(controller, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          _buildHandle(),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 16),
          _buildAvatarEditor(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Edit Profile',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00FFEB),
      ),
    );
  }

  Widget _buildAvatarEditor() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00FFEB), width: 3),
          ),
          child: ClipOval(
            child: Container(
              color: Colors.grey[800],
              child: Icon(profile.avatarIcon, color: Colors.white, size: 60),
            ),
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF00FFEB),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt,
            color: Color(0xFF0F0027),
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ScrollController controller, BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        _EditField(label: 'Full Name', initialValue: profile.name),
        _EditField(label: 'Email', initialValue: profile.email),
        _EditField(label: 'Phone', initialValue: profile.phone),
        _EditField(label: 'Address', initialValue: profile.address),
        const SizedBox(height: 30),
        _buildSaveButton(context),
        const SizedBox(height: 16),
        _buildCancelButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: const Color(0xFF0F0027),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor: const Color(0xFF00FFEB),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFEB),
        foregroundColor: const Color(0xFF0F0027),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Save Changes',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(foregroundColor: Colors.white70),
      child: const Text('Cancel'),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.initialValue,
  });

  final String label;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF545877).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: TextEditingController(text: initialValue),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
