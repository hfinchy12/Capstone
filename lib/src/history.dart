import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  String imgPath;
  String jsonAnalysis;
  int overallScore;

  HistoryEntry(this.imgPath, this.jsonAnalysis, this.overallScore);

  Map toJson() {
    return {
      "imgPath": imgPath,
      "jsonAnalysis": jsonAnalysis,
      "overallScore": overallScore
    };
  }

  HistoryEntry.fromJson(Map<String, dynamic> json)
      : imgPath = json["imgPath"] ?? "",
        jsonAnalysis = json["jsonAnalysis"] ?? "",
        overallScore = json["overallScore"] ?? 100;
}

class History {
  static const key = "history_key";

  static Future<void> append(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> arr = List.empty(growable: true);

    if (prefs.containsKey(key) && prefs.getStringList(key) != null) {
      arr = prefs.getStringList(key)!.toList(growable: true);
    }

    arr.insert(0, jsonEncode(entry));
    prefs.setStringList(key, arr);
  }

  static Future<void> remove(int index) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key) && prefs.getStringList(key) != null) {
      List<String> history = prefs.getStringList(key)!.toList(growable: true);
      history.removeAt(index);
      prefs.setStringList(key, history);
    }
  }

  static Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonHistory = prefs.getStringList(key) ?? [];
    final List<HistoryEntry> history =
        jsonHistory.map((e) => HistoryEntry.fromJson(jsonDecode(e))).toList();
    return history;
  }
}
