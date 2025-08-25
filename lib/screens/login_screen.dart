import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../routes/route_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(); // Changed from _usernameController
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose(); // Changed from _usernameController
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // First try to authenticate with Firebase Auth
      UserCredential? userCredential = await _firebaseService
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (userCredential != null) {
        // Get user data from Firestore using the authenticated user's email
        UserModel? user = await _firebaseService.getUserByEmail(
          _emailController.text.trim(),
        );

        if (user != null) {
          // Login successful
          if (user.role == 'admin') {
            RouteHelper.navigateToHomeAdmin(context, user);
          } else {
            RouteHelper.navigateToHomePasien(context, user);
          }
        } else {
          // User exists in Auth but not in Firestore - create Firestore record
          print(
            'User authenticated but not found in Firestore, creating record...',
          );

          // Check if this is an admin user based on email
          String userRole = 'pasien';
          String userName = 'User';

          if (_emailController.text.trim().toLowerCase() == 'admin@gmail.com') {
            userRole = 'admin';
            userName = 'Admin';
          }

          final newUser = UserModel(
            id: userCredential.user!.uid,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            nama: userName,
            noHp: '',
            alamat: '',
            tanggalLahir: DateTime.now(),
            umur: 0,
            role: userRole,
            createdAt: DateTime.now(),

            // New fields with default values
            namaSuami: null,
            pekerjaanSuami: null,
            umurSuami: null,
            agamaSuami: null,
            agamaPasien: null,
            pekerjaanPasien: null,
          );

          await _firebaseService.createUser(newUser);

          if (userRole == 'admin') {
            RouteHelper.navigateToHomeAdmin(context, newUser);
          } else {
            RouteHelper.navigateToHomePasien(context, newUser);
          }
        }
      } else {
        // Fallback: try direct Firestore authentication (for existing users)
        UserModel? user = await _firebaseService.getUserByEmail(
          _emailController.text.trim(),
        );

        if (user != null && user.password == _passwordController.text) {
          // Login successful with Firestore
          if (user.role == 'admin') {
            RouteHelper.navigateToHomeAdmin(context, user);
          } else {
            RouteHelper.navigateToHomePasien(context, user);
          }
        } else {
          // Login failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email atau password salah!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Login error: $e');

      // Try fallback authentication
      try {
        UserModel? user = await _firebaseService.getUserByEmail(
          _emailController.text.trim(),
        );

        if (user != null && user.password == _passwordController.text) {
          // Login successful with Firestore fallback
          if (user.role == 'admin') {
            RouteHelper.navigateToHomeAdmin(context, user);
          } else {
            RouteHelper.navigateToHomePasien(context, user);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email atau password salah!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (fallbackError) {
        print('Fallback login error: $fallbackError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    RouteHelper.navigateToRegister(context);
  }

  void _navigateToForgotPassword() {
    RouteHelper.navigateToForgotPassword(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Top Section - Title
              const SizedBox(height: 20),
              Text(
                'Persalinanku',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),

              // Logo Section
              Container(
                width: 480,
                height: 500,
                child: Image.asset(
                  'assets/icons/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 6),

              // Main Message
              Text(
                'Simpan riwayat persalinanmu dengan aman',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Secondary Text
              Text(
                'Daftar Sekarang atau Login Dengan Akun Anda',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Bottom Section - Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Username Field
                      TextFormField(
                        controller:
                            _emailController, // Changed from _usernameController
                        decoration: InputDecoration(
                          labelText: 'Email', // Changed from Username
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.grey[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF20B2AA),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong'; // Changed from Username
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF20B2AA),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20B2AA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'MASUK',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: _navigateToRegister,
                            child: Text(
                              'Daftar Sekarang',
                              style: GoogleFonts.poppins(
                                color: Colors.red[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: Text(
                            'Lupa Password?',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF20B2AA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
