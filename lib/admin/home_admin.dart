import 'package:flutter/material.dart';
import '../utilities/safe_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';

import '../../services/notification_listener_service.dart';
import '../../services/notification_service.dart';

import '../../routes/route_helper.dart';
import 'data_pasien.dart';
import 'registrasi_persalinan.dart';
import 'chat_admin.dart';
import 'data_persalinan.dart';
import '../widgets/simple_notification_badge.dart';
import '../screens/notification_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  final UserModel user;

  const HomeAdminScreen({super.key, required this.user});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Initialize notification service and listeners
    _initializeNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Dispose notification listeners
    NotificationListenerService.dispose();
    super.dispose();
  }

  // Initialize notification service and listeners
  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
    NotificationListenerService.initializeAdminListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100, // Account for bottom nav
                ),
                child: _buildDashboard(),
              ),
            ),
          ),
          const DataPasienScreen(),
          const RegistrasiPersalinanScreen(),
          const DataPersalinanScreen(),
          const ChatAdminScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
              _buildNavItem(Icons.people_rounded, 'Pasien', 1),
              _buildNavItem(Icons.medical_services_rounded, 'Registrasi', 2),
              _buildNavItem(Icons.local_hospital_rounded, 'Laporan', 3),
              _buildNavItem(Icons.chat_rounded, 'Chat', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEC407A) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Stack(
      children: [
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Header Section with enhanced design
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.user.nama.isNotEmpty ? widget.user.nama : 'Admin'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Admin Sistem Persalinan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFEC407A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildNotificationIcon(() {
                                // Navigate to notification screen
                                RouteHelper.navigateToNotification(
                                  context,
                                  widget.user,
                                );
                              }),
                              const SizedBox(width: 12),
                              _buildHeaderIcon(Icons.person_rounded, () {
                                _showLogoutDialog();
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEC407A),
                            const Color(0xFFEC407A).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFEC407A,
                            ).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kelola data pasien dan konsultasi dengan mudah',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildActionButton(
                          Icons.people_rounded,
                          'Data Pasien',
                          () => setState(() => _selectedIndex = 1),
                        ),
                        _buildActionButton(
                          Icons.medical_services_rounded,
                          'Registrasi',
                          () => setState(() => _selectedIndex = 2),
                        ),
                        _buildActionButton(
                          Icons.local_hospital_rounded,
                          'Laporan',
                          () => setState(() => _selectedIndex = 3),
                        ),
                        _buildActionButton(
                          Icons.chat_rounded,
                          'Chat',
                          () => setState(() => _selectedIndex = 4),
                        ),
                        _buildActionButton(
                          Icons.analytics_rounded,
                          'Analitik',
                          () => RouteHelper.navigateToAnalytics(
                            context,
                            widget.user,
                          ),
                        ),
                        _buildActionButton(
                          Icons.pregnant_woman_rounded,
                          'Pemeriksaan',
                          () => RouteHelper.navigateToPemeriksaanIbuHamil(
                            context,
                            widget.user,
                          ),
                        ),
                        _buildActionButton(
                          Icons.schedule_rounded,
                          'Temu Janji',
                          () => RouteHelper.navigateToJadwalKonsultasi(
                            context,
                            widget.user,
                          ),
                        ),
                        _buildActionButton(
                          Icons.school_rounded,
                          'Edukasi',
                          () => RouteHelper.navigateToPanelEdukasi(
                            context,
                            widget.user,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(VoidCallback onTap) {
    return NotificationIconWithBadge(
      icon: Icons.notifications,
      onPressed: onTap,
      iconColor: const Color(0xFFEC407A),
      badgeColor: Colors.red,
      textColor: Colors.white,
      badgeSize: 20,
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEC407A).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFEC407A), size: 20),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: const Color(0xFFEC407A), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin keluar?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => NavigationHelper.safeNavigateBack(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  NavigationHelper.safeNavigateBack(context);
                  RouteHelper.navigateToLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC407A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Logout', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }
}
