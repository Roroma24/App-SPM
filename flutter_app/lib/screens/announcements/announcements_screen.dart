import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Text(
          "Anuncios",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      body: ListView(
        padding: const EdgeInsets.all(24),

        children: [
          /// TITULO
          Text(
            "Comunicación Institucional",
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Anuncios.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 30),

          /// CARD 1
          _announcementCard(
            category: "Academia",
            title: "Asegura tu futuro",
            description:
                "Paga tu RVOE para garantizar tu inscripción al siguiente semestre.",
            color: AppColors.primary,
          ),

          const SizedBox(height: 20),

          /// CARD 2
          _announcementCard(
            category: "Eventos",
            title: "Conferencia Magistral: IA en la Educación Superior",
            description:
                "Únete a la charla con expertos globales sobre modelos generativos.",
            color: Colors.indigo,
          ),

          const SizedBox(height: 20),

          /// CARD 3
          _announcementCard(
            category: "Avisos",
            title: "Mantenimiento de Blackboard",
            description: "La plataforma no estará disponible temporalmente.",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _announcementCard({
    required String category,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        border: Border.all(color: color.withOpacity(0.15)),

        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.04)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// CATEGORY
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),

            child: Text(
              category,

              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(height: 22),

          /// TITLE
          Text(
            title,

            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          /// DESCRIPTION
          Text(
            description,

            style: GoogleFonts.inter(
              height: 1.5,
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 24),

          /// BUTTON
          Row(
            children: [
              Text(
                "Leer más",

                style: GoogleFonts.inter(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 8),

              Icon(Icons.arrow_forward, color: color, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
