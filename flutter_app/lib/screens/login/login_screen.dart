import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../home/home_screen.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              children: [
                const SizedBox(height: 30),

                /// LOGO
                Container(
                  width: 130,
                  height: 130,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ],
                  ),

                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Logo_UVM_Rojo.svg/1280px-Logo_UVM_Rojo.svg.png',
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Linceate!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Bienvenido a tu futuro académico',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 50),

                /// CARD LOGIN
                Container(
                  padding: const EdgeInsets.all(28),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 30,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      /// CORREO
                      TextField(
                        controller: correoController,

                        decoration: InputDecoration(
                          labelText: 'Correo Institucional',
                          prefixIcon: const Icon(Icons.email_outlined),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: true,

                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      /// BOTON LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 58,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });

                            final response = await ApiService.login(
                              correoController.text,
                              passwordController.text,
                            );

                            setState(() {
                              loading = false;
                            });

                            if (response["success"] == true ||
                                response["success"].toString() == "true") {
                              final userSession = response["user"] ?? {};
                              
                              if (mounted) {
                                // Guardar sesión en Provider
                                context.read<UserProvider>().setUserSession(userSession);
                                
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response["message"])),
                              );
                            }
                          },

                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Iniciar Sesión',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
}
