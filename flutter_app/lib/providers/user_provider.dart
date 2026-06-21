import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic> _userSession = {};
  int _unreadNotificationsCount = 0;

  Map<String, dynamic> get userSession => _userSession;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  void setUserSession(Map<String, dynamic> user) {
    _userSession = user;
    notifyListeners();
  }

  void updateUserField(String field, dynamic value) {
    _userSession[field] = value;
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic> updatedData) {
    _userSession.addAll(updatedData);
    notifyListeners();
  }

  void setUnreadNotificationsCount(int count) {
    _unreadNotificationsCount = count;
    notifyListeners();
  }

  void notifyChange() {
    notifyListeners();
  }

  void logout() {
    _userSession = {};
    _unreadNotificationsCount = 0;
    notifyListeners();
  }
}
