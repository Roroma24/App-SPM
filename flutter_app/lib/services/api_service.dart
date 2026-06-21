import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000";

  // ================= USUARIOS =================
  static Future<Map<String, dynamic>> login(
    String correo,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"correo": correo, "password": password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile(
    String userId,
    String alias,
    String campus,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile/$userId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "alias": alias,
        "campus": campus,
      }),
    );

    return jsonDecode(response.body);
  }

  // ================= ANUNCIOS =================
  static Future<List<dynamic>> getAnnouncements() async {
    final response = await http.get(Uri.parse("$baseUrl/announcements"));

    return jsonDecode(response.body);
  }

  // ================= PUBLICACIONES =================
  static Future<Map<String, dynamic>> createPublication(
    String userId,
    String userAlias,
    String userName,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/publications"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "user_alias": userAlias,
        "user_name": userName,
        "content": content,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPublications({
    String search = "",
    String filterBy = "date", // date, user, age
  }) async {
    final uri = Uri.parse(
      "$baseUrl/publications?search=$search&filter_by=$filterBy",
    );

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleLike(
    String publicationId,
    String userId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/publications/$publicationId/like"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleDislike(
    String publicationId,
    String userId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/publications/$publicationId/dislike"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePublication(
    String publicationId,
    String userId,
    String content,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/publications/$publicationId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "content": content,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deletePublication(
    String publicationId,
  ) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/publications/$publicationId"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  // ================= NOTIFICACIONES =================
  static Future<Map<String, dynamic>> getNotifications(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/notifications/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/notifications/$notificationId/read"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markNotificationAsUnread(
    String notificationId,
  ) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/notifications/$notificationId/unread"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
    String userId,
  ) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/notifications/$userId/mark-all-read"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleNotificationsPreference(
    String userId,
    bool enabled,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile/$userId/notifications-toggle"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"notifications_enabled": enabled}),
    );

    return jsonDecode(response.body);
  }
}
