import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:basalmetabolism/l10n/app_localizations.dart';

class Model {
  Model._();

  static const String _prefHumanHeight = 'humanHeight';
  static const String _prefHumanWeight = 'humanWeight';
  static const String _prefHumanAge = 'humanAge';
  static const String _prefHumanGender = 'humanGender';
  static const String _prefSchemeColor = 'schemeColor';
  static const String _prefThemeNumber = 'themeNumber';
  static const String _prefLanguageCode = 'languageCode';

  static bool _ready = false;
  static int _humanHeight = 160;
  static int _humanWeight = 60;
  static int _humanAge = 30;
  static int _humanGender = 2;  //1:male, 2:female
  static int _schemeColor = 200;
  static int _themeNumber = 0;
  static String _languageCode = '';

  static int get humanHeight => _humanHeight;
  static int get humanWeight => _humanWeight;
  static int get humanAge => _humanAge;
  static int get humanGender => _humanGender;
  static int get schemeColor => _schemeColor;
  static int get themeNumber => _themeNumber;
  static String get languageCode => _languageCode;

  static Future<void> ensureReady() async {
    if (_ready) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    _humanHeight = (prefs.getInt(_prefHumanHeight) ?? 160).clamp(1, 300);
    _humanWeight = (prefs.getInt(_prefHumanWeight) ?? 60).clamp(1, 999);
    _humanAge = (prefs.getInt(_prefHumanAge) ?? 30).clamp(1, 200);
    _humanGender = (prefs.getInt(_prefHumanGender) ?? 2).clamp(1, 2);
    _schemeColor = (prefs.getInt(_prefSchemeColor) ?? 200).clamp(0, 360);
    _themeNumber = (prefs.getInt(_prefThemeNumber) ?? 0).clamp(0, 2);
    _languageCode = prefs.getString(_prefLanguageCode) ?? ui.PlatformDispatcher.instance.locale.languageCode;
    _languageCode = _resolveLanguageCode(_languageCode);
    _ready = true;
  }

  static String _resolveLanguageCode(String code) {
    final supported = AppLocalizations.supportedLocales;
    if (supported.any((l) => l.languageCode == code)) {
      return code;
    } else {
      return '';
    }
  }

  static Future<void> setHumanHeight(int value) async {
    _humanHeight = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHumanHeight, value);
  }

  static Future<void> setHumanWeight(int value) async {
    _humanWeight = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHumanWeight, value);
  }

  static Future<void> setHumanAge(int value) async {
    _humanAge = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHumanAge, value);
  }

  static Future<void> setHumanGender(int value) async {
    _humanGender = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHumanGender, value);
  }

  static Future<void> setSchemeColor(int value) async {
    _schemeColor = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefSchemeColor, value);
  }

  static Future<void> setThemeNumber(int value) async {
    _themeNumber = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefThemeNumber, value);
  }

  static Future<void> setLanguageCode(String value) async {
    _languageCode = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageCode, value);
  }

}
