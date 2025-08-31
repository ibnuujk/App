import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mixin untuk safe navigation yang mencegah crash/blank screen
/// Digunakan untuk semua screen admin
mixin SafeNavigationMixin<T extends StatefulWidget> on State<T> {
  bool _isNavigating = false;

  /// Safe navigation back with checks and error handling
  Future<void> safeNavigateBack() async {
    if (_isNavigating) return; // Prevent double navigation

    _isNavigating = true;

    try {
      // Add small delay to prevent race conditions
      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Navigation error: $e');
      // If navigation fails, try to force reset navigation state
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _isNavigating = false;
        });
      }
    } finally {
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  /// Safe navigation push with error handling
  Future<T?> safeNavigateTo<T>(Widget destination) async {
    if (_isNavigating) return null;

    _isNavigating = true;

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted) {
        final result = await Navigator.push<T>(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
        return result;
      }
    } catch (e) {
      print('Navigation error: $e');
    } finally {
      if (mounted) {
        _isNavigating = false;
      }
    }
    return null;
  }

  /// Safe dialog close
  void safeCloseDialog() {
    if (_isNavigating || !mounted) return;

    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Dialog close error: $e');
    }
  }

  /// Reset navigation state - call in dispose if needed
  void resetNavigationState() {
    _isNavigating = false;
  }

  /// Safe AppBar leading widget
  Widget buildSafeBackButton({
    Color iconColor = Colors.white,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: iconColor),
      onPressed: onPressed ?? safeNavigateBack,
    );
  }

  /// Safe PopScope wrapper for handling back gesture
  Widget buildSafePopScope({
    required Widget child,
    bool canPop = true,
    void Function(bool, Object?)? onPopInvokedWithResult,
  }) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult:
          onPopInvokedWithResult ??
          (didPop, result) {
            if (didPop) {
              print('Back navigation completed');
            }
          },
      child: child,
    );
  }
}

/// Utility class for static navigation helpers
class NavigationHelper {
  /// Safe static navigation method
  static Future<void> safeNavigateBack(BuildContext context) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Static navigation error: $e');
    }
  }

  /// Safe static navigation push
  static Future<T?> safeNavigateTo<T>(
    BuildContext context,
    Widget destination,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final result = await Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
      return result;
    } catch (e) {
      print('Static navigation push error: $e');
      return null;
    }
  }

  /// Create safe AppBar with back button
  static PreferredSizeWidget buildSafeAppBar({
    required String title,
    Color backgroundColor = const Color(0xFFEC407A),
    Color titleColor = Colors.white,
    Color iconColor = Colors.white,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    double elevation = 0,
    required BuildContext context,
  }) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: onBackPressed ?? () => safeNavigateBack(context),
      ),
      actions: actions,
    );
  }
}
