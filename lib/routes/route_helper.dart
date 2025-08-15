import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../screens/register.dart';
import '../screens/hpht_form.dart';
import '../admin/home_admin.dart';
import '../admin/data_pasien.dart';
import '../admin/data_konsultasi_pasien.dart';
import '../admin/registrasi_persalinan.dart';
import '../admin/chat_admin.dart';
import '../admin/pemeriksaan_ibuhamil.dart';
import '../admin/jadwal_konsultasi.dart';
import '../admin/analytics_screen.dart';
import '../pasien/home_pasien.dart';
import '../pasien/kehamilanku.dart';
import '../pasien/pemeriksaan.dart';
// import '../pasien/darurat.dart';
import '../pasien/profile.dart';
import '../pasien/konsultasi_pasien.dart';
import '../pasien/chat_pasien.dart';
import '../pasien/temu_janji.dart';
import '../pasien/edukasi.dart';
import '../pasien/jadwal_pasien.dart';
import '../pasien/emergency_screen.dart';

class RouteHelper {
  static const String login = '/login';
  static const String register = '/register';
  static const String hphtForm = '/hpht-form';
  static const String homeAdmin = '/home-admin';
  static const String homePasien = '/home-pasien';
  static const String dataPasien = '/data-pasien';
  static const String dataKonsultasi = '/data-konsultasi';
  static const String registrasiPersalinan = '/registrasi-persalinan';
  static const String chatAdmin = '/chat-admin';
  static const String pemeriksaanIbuHamil = '/pemeriksaan-ibuhamil';
  static const String jadwalKonsultasi = '/jadwal-konsultasi';
  static const String analytics = '/analytics';
  static const String educationManagement = '/education-management';

  static const String kehamilanku = '/kehamilanku';
  static const String pemeriksaan = '/pemeriksaan';
  static const String darurat = '/darurat';
  static const String konsultasiPasien = '/konsultasi-pasien';
  static const String chatPasien = '/chat-pasien';
  static const String profile = '/profile';
  static const String temuJanji = '/temu-janji';
  static const String edukasi = '/edukasi';
  static const String jadwalPasien = '/jadwal-pasien';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case hphtForm:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => HPHTFormScreen(user: user));

      case homeAdmin:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => HomeAdminScreen(user: user));

      case homePasien:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => HomePasienScreen(user: user));

      case dataPasien:
        return MaterialPageRoute(builder: (_) => const DataPasienScreen());

      case dataKonsultasi:
        return MaterialPageRoute(
          builder: (_) => const DataKonsultasiPasienScreen(),
        );

      case registrasiPersalinan:
        return MaterialPageRoute(
          builder: (_) => const RegistrasiPersalinanScreen(),
        );

      case chatAdmin:
        return MaterialPageRoute(builder: (_) => const ChatAdminScreen());

      case pemeriksaanIbuHamil:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => PemeriksaanIbuHamilScreen(user: user),
        );

      case jadwalKonsultasi:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => JadwalKonsultasiScreen(user: user),
        );

      case analytics:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => AnalyticsScreen(user: user));

      case educationManagement:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Education Management'),
                  backgroundColor: const Color(0xFFEC407A),
                  foregroundColor: Colors.white,
                ),
                body: const Center(
                  child: Text('Education Management - Coming Soon'),
                ),
              ),
        );

      case kehamilanku:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => KehamilankuScreen(user: user));

      case pemeriksaan:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => PemeriksaanScreen(user: user));

      case darurat:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => EmergencyScreen(user: user));

      case profile:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => ProfileScreen(user: user));

      case konsultasiPasien:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => KonsultasiPasienScreen(user: user),
        );

      case chatPasien:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => ChatPasienScreen(user: user));

      case temuJanji:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => TemuJanjiScreen(user: user));

      case edukasi:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => EdukasiScreen(user: user));

      case jadwalPasien:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => JadwalPasienScreen(user: user),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }

  // Helper methods for navigation
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }

  static void navigateToHPHTForm(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, hphtForm, arguments: user);
  }

  static void navigateToHomeAdmin(BuildContext context, UserModel user) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      homeAdmin,
      arguments: user,
      (route) => false,
    );
  }

  static void navigateToHomePasien(BuildContext context, UserModel user) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      homePasien,
      arguments: user,
      (route) => false,
    );
  }

  static void navigateToDataPasien(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, dataPasien, arguments: user);
  }

  static void navigateToDataKonsultasi(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, dataKonsultasi, arguments: user);
  }

  static void navigateToRegistrasiPersalinan(
    BuildContext context,
    UserModel user,
  ) {
    Navigator.pushNamed(context, registrasiPersalinan, arguments: user);
  }

  static void navigateToChatAdmin(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, chatAdmin, arguments: user);
  }

  static void navigateToPemeriksaanIbuHamil(
    BuildContext context,
    UserModel user,
  ) {
    Navigator.pushNamed(context, pemeriksaanIbuHamil, arguments: user);
  }

  static void navigateToJadwalKonsultasi(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, jadwalKonsultasi, arguments: user);
  }

  static void navigateToAnalytics(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, analytics, arguments: user);
  }

  static void navigateToEducationManagement(
    BuildContext context,
    UserModel user,
  ) {
    Navigator.pushNamed(context, educationManagement, arguments: user);
  }

  static void navigateToKehamilanku(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, kehamilanku, arguments: user);
  }

  static void navigateToPemeriksaan(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, pemeriksaan, arguments: user);
  }

  static void navigateToProfile(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, profile, arguments: user);
  }

  static void navigateToKonsultasiPasien(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, konsultasiPasien, arguments: user);
  }

  static void navigateToChatPasien(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, chatPasien, arguments: user);
  }

  static void navigateToTemuJanji(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, temuJanji, arguments: user);
  }

  static void navigateToEdukasi(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, edukasi, arguments: user);
  }

  static void navigateToDarurat(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, darurat, arguments: user);
  }

  static void navigateToJadwalPasien(BuildContext context, UserModel user) {
    Navigator.pushNamed(context, jadwalPasien, arguments: user);
  }

  static void navigateToRiwayatPemeriksaan(
    BuildContext context,
    UserModel user,
  ) {
    Navigator.pushNamed(context, pemeriksaan, arguments: user);
  }

  // Navigation with replacement
  static void replaceToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void replaceToHomeAdmin(BuildContext context, UserModel user) {
    Navigator.pushReplacementNamed(context, homeAdmin, arguments: user);
  }

  static void replaceToHomePasien(BuildContext context, UserModel user) {
    Navigator.pushReplacementNamed(context, homePasien, arguments: user);
  }

  // Pop navigation
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goBackToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
