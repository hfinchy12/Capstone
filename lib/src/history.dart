library photo_history;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  String imgPath;
  Map<String, dynamic> analysis;
  Color ratingColor;

  HistoryEntry(this.imgPath, this.analysis, this.ratingColor);

  Map toJson() {
    return {
      "imgPath": imgPath,
      "analysis": analysis,
      "ratingColor": ratingColor.value
    };
  }

  HistoryEntry.fromJson(Map<String, dynamic> json)
      : imgPath = json["imgPath"] ?? "",
        analysis = json["analysis"] ?? {},
        ratingColor = Color(json["ratingColor"] ?? Colors.black.value);
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
      HistoryEntry entry = HistoryEntry.fromJson(jsonDecode(history[index]));
      File(entry.imgPath).delete();
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
