library photo_history;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The [HistoryEntry] class stores the data relating to the analysis of a photo.
class HistoryEntry {
  /// The path on disk of the image.
  String imgPath;

  /// The analysis data of the image.
  Map<String, dynamic> analysis;

  /// The color for the rating of the image.
  Color ratingColor;

  /// Constructs a [HistoryEntry] and sets the [imgPath], [analysis], and [ratingColor].
  HistoryEntry(this.imgPath, this.analysis, this.ratingColor);

  /// Converts the [HistoryEntry] object to a json [Map] object.
  Map toJson() {
    return {
      "imgPath": imgPath,
      "analysis": analysis,
      "ratingColor": ratingColor.value
    };
  }

  /// Converts a json [Map] object to a [HistoryEntry] object.
  HistoryEntry.fromJson(Map<String, dynamic> json)
      : imgPath = json["imgPath"] ?? "",
        analysis = json["analysis"] ?? {},
        ratingColor = Color(json["ratingColor"] ?? Colors.black.value);
}

/// The [History] class contains logic to append, remove, and get the user's analysis history.
class History {
  /// The key to access the history on disk.
  static const key = "history_key";

  /// Appends a new [HistoryEntry] object to disk.
  static Future<void> append(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> arr = List.empty(growable: true);

    if (prefs.containsKey(key) && prefs.getStringList(key) != null) {
      arr = prefs.getStringList(key)!.toList(growable: true);
    }

    arr.insert(0, jsonEncode(entry));
    prefs.setStringList(key, arr);
  }

  /// Removes a [HistoryEntry] object from disk by index.
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

  /// Returns an [List] of [HistoryEntry] objects from disk.
  static Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonHistory = prefs.getStringList(key) ?? [];
    final List<HistoryEntry> history =
        jsonHistory.map((e) => HistoryEntry.fromJson(jsonDecode(e))).toList();
    return history;
  }
}
