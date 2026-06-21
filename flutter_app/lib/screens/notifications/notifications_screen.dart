import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userSession['_id'] ?? '';

    try {
      final response = await ApiService.getNotifications(userId);

      if (response['success'] == true) {
        setState(() {
          notifications = List<Map<String, dynamic>>.from(response['notifications'] ?? []);
          isLoading = false;
        });
        userProvider.setUnreadNotificationsCount(response['unread_count'] ?? 0);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notificaciones: $e')),
        );
      }
    }
  }

  Future<void> _toggleNotificationRead(String notifId, bool currentRead) async {
    try {
      late Map<String, dynamic> response;

      if (currentRead) {
        response = await ApiService.markNotificationAsUnread(notifId);
      } else {
        response = await ApiService.markNotificationAsRead(notifId);
      }

      if (response['success'] == true) {
        // Recargar notificaciones
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userSession['_id'] ?? '';

    try {
      final response = await ApiService.markAllNotificationsAsRead(userId);

      if (response['success'] == true) {
        _loadNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todas marcadas como leídas')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final parsed = DateTime.parse(dateTime);
      final adjusted = parsed.add(const Duration(hours: -6));
      return DateFormat('dd/MM/yyyy HH:mm').format(adjusted);
    } catch (e) {
      return dateTime;
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
          'Notificaciones',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (notifications.any((n) => n['is_read'] == false))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Marcar todo como leído',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes notificaciones',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final isRead = notif['is_read'] == true;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: isRead ? Colors.white : const Color(0xFFFFF3F0),
                      child: ListTile(
                        leading: Icon(
                          _getIconForType(notif['type']),
                          color: isRead ? AppColors.textSecondary : AppColors.primary,
                        ),
                        title: Text(
                          notif['title'] ?? 'Notificación',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notif['message'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(notif['created_at'] ?? ''),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        trailing: InkWell(
                          onTap: () => _toggleNotificationRead(notif['_id'], isRead),
                          child: Icon(
                            isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        onTap: () => _toggleNotificationRead(notif['_id'], isRead),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'announcement':
        return Icons.campaign;
      case 'system':
        return Icons.info;
      case 'message':
        return Icons.message;
      case 'publication':
        return Icons.post_add;
      default:
        return Icons.notifications;
    }
  }
}
