import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/store_keys.dart';

class LocalStorageService {
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(StoreKeys.chatHistory) ?? [];
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> saveMessage(Map<String, dynamic> msg) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(StoreKeys.chatHistory) ?? [];
    raw.add(jsonEncode(msg));
    await prefs.setStringList(StoreKeys.chatHistory, raw);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
}