import 'package:khiem_vais_test/model/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _keyTaskList = 'taskList';
  static const String _keyIsDarkMode = 'isDarkMode';

  static Future<void> saveIsDarkMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, isDarkMode);
  }

  static Future<bool> getIsDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? true;
  }

  static Future<void> saveTaskList(List<Task> taskList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskListJson = taskList.map((task) => task.toJson()).toList();
    await prefs.setStringList(_keyTaskList, taskListJson);
  }

  static Future<List<Task>> getTaskList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskListJson = prefs.getStringList(_keyTaskList);
    if (taskListJson != null) {
      return taskListJson.map((json) => Task.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
