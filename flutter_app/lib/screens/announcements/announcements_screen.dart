import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late Future<List<dynamic>> announcementsFuture;

  @override
  void initState() {
    super.initState();

    announcementsFuture = ApiService.getAnnouncements();
  }

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

      body: FutureBuilder<List<dynamic>>(
        future: announcementsFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar anuncios",
                style: GoogleFonts.inter(),
              ),
            );
          }

          final announcements = snapshot.data ?? [];

          return ListView(
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

              ...announcements.map((announcement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),

                  child: _announcementCard(
                    context: context,
                    announcement: announcement,
                    category: announcement["category"] ?? "",
                    title: announcement["title"] ?? "",
                    description: announcement["description"] ?? "",
                    color: _getColor(announcement["category"] ?? ""),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Color _getColor(String category) {
    switch (category.toLowerCase()) {
      case "academia":
        return AppColors.primary;

      case "eventos":
        return Colors.indigo;

      case "avisos":
        return Colors.orange;

      case "becas":
        return Colors.green;

      case "deportes":
        return Colors.red;

      case "biblioteca":
        return Colors.teal;

      case "movilidad":
        return Colors.purple;

      case "empleo":
        return Colors.blue;

      default:
        return AppColors.primary;
    }
  }

  Widget _announcementCard({
    required BuildContext context,
    required Map<String, dynamic> announcement,
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

          /// BOTON LEER MAS
          InkWell(
            onTap: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      AnnouncementDetailScreen(announcement: announcement),
                ),
              );
            },

            child: Row(
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
          ),
        ],
      ),
    );
  }
}
