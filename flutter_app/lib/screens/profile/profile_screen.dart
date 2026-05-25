import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          'Perfil',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://cdn-icons-png.flaticon.com/512/12225/12225881.png',
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Casta_San',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Ingeniería en Sistemas',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 40),

            _infoTile(Icons.badge, 'Matrícula', '010145666'),

            const SizedBox(height: 20),

            _infoTile(
              Icons.email_outlined,
              'Correo',
              'a010145666@my.uvm.edu.mx',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.04)),
        ],
      ),

      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
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
