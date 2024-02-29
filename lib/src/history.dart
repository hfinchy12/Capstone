import 'package:shared_preferences/shared_preferences.dart';

class History {
  static const historyPathKey = "history_path";
  static const historyAnalysesKey = "history_analyses";

  static void _append(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> arr = List.empty(growable: true);

    if (prefs.containsKey(key) && prefs.getStringList(key) != null) {
      arr = prefs.getStringList(key)!.toList(growable: true);
    }

    arr.insert(0, value);
    prefs.setStringList(key, arr);
  }

  static void appendHistory(String imgPath, String strJsonAnalysis) async {
    _append(historyPathKey, imgPath);
    _append(historyAnalysesKey, strJsonAnalysis);
  }

  static void _remove(String key, int index) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key) && prefs.getStringList(key) != null) {
      List<String> historyPaths =
          prefs.getStringList(key)!.toList(growable: true);
      historyPaths.removeAt(index);
      prefs.setStringList(key, historyPaths);
    }
  }

  static void removeHistory(int index) async {
    _remove(historyPathKey, index);
    _remove(historyAnalysesKey, index);
  }

  static Future<List<String>> getHistoryPaths() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyPaths = prefs.getStringList(historyPathKey);
    return historyPaths == null ? [] : historyPaths.toList();
  }

  static Future<List<String>> getHistoryAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyPaths = prefs.getStringList(historyAnalysesKey);
    return historyPaths == null ? [] : historyPaths.toList();
  }
}
