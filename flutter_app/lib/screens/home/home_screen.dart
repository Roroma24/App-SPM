import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';

import '../announcements/announcements_screen.dart';
import '../wall/wall_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // =========================
  // ABRIR REPOSITORIO
  // =========================
  Future<void> abrirRepositorio() async {
    final Uri url = Uri.parse(
      'https://myuvmedu-my.sharepoint.com/:f:/g/personal/a010145666_my_uvm_edu_mx/IgBs4DUGBYSxSpYxl-bQi8OVAa_XeUxkKb0evrvmtp54u7A?e=ndaTX9',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Text(
          'Linceate!',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            color: AppColors.textPrimary,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Hola, Estudiante',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Bienvenido nuevamente',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,

                children: [
                  /// ANUNCIOS
                  _buildCard(
                    context: context,
                    icon: Icons.campaign,
                    title: 'Anuncios',

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const AnnouncementsScreen(),
                        ),
                      );
                    },
                  ),

                  /// MURO
                  _buildCard(
                    context: context,
                    icon: Icons.forum,
                    title: 'Muro',

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(builder: (_) => const WallScreen()),
                      );
                    },
                  ),

                  /// REPOSITORIO
                  _buildCard(
                    context: context,
                    icon: Icons.folder,
                    title: 'Repositorio',

                    onTap: () {
                      abrirRepositorio();
                    },
                  ),

                  /// PERFIL
                  _buildCard(
                    context: context,
                    icon: Icons.person,
                    title: 'Perfil',

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // CARD
  // =========================
  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.04)),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 34,

              backgroundColor: AppColors.primary.withOpacity(0.08),

              child: Icon(icon, color: AppColors.primary, size: 34),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
