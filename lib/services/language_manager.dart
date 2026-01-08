import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;

  LanguageManager._internal() {
    _loadLanguage();
  }

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale type) async {
    final prefs = await SharedPreferences.getInstance();
    if (_locale == type) return;
    
    if (type.languageCode == 'hi') {
      _locale = const Locale('hi');
    } else if (type.languageCode == 'kn') {
      _locale = const Locale('kn');
    } else {
      _locale = const Locale('en');
    }
    
    await prefs.setString('language_code', _locale.languageCode);
    notifyListeners();
  }
}
