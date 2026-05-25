import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class WallScreen extends StatelessWidget {
  const WallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,

        onPressed: () {},

        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            /// HEADER
            Text(
              "Muro de",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            Text(
              "Expresión Lince",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Comparte ideas con la comunidad.",
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            /// SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar publicaciones",

                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// POSTS
            _postCard(
              user: "@Sofi_Lince",
              time: "Hace 2 horas",

              text:
                  "Mucho éxito a todos en semana de parciales. Sí se puede linces.",

              likes: 12,
            ),

            const SizedBox(height: 20),

            _postCard(
              user: "@Casta_san",
              time: "Hace 4 horas",

              text: "¿Se cayó Blackboard? No me abre para mis tareas.",

              likes: 3,
            ),

            const SizedBox(height: 20),

            _postCard(
              user: "@Sebas_Punk",
              time: "Hace 6 horas",

              text: "Emocionado por el Hackaton con el profesor Ríos.",

              likes: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard({
    required String user,
    required String time,
    required String text,
    required int likes,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.04)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// USER
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.08),

                child: Icon(Icons.person, color: AppColors.primary),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    user,

                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  Text(
                    time,

                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// TEXT
          Text(
            text,

            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          /// ACTIONS
          Row(
            children: [
              Icon(
                Icons.thumb_up_alt_outlined,
                color: AppColors.primary,
                size: 20,
              ),

              const SizedBox(width: 6),

              Text(
                likes.toString(),

                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 20),

              Icon(
                Icons.thumb_down_alt_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
