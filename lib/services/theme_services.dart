import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//get storage will save stuff locally to device


class ThemeServices{
  //this will save a boolean status for our app theme
  final _box = GetStorage();
  final _key = 'isDarkMode';

  //this will save the current selected theme
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  //if theres a value, return that value else return false
  bool _loadThemeFromBox() => _box.read(_key)??false;

  //if function returns true,fallback to dark mode else light mode (Theres no value for _key at first so it'll return false by default i.e light mode)
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  void switchTheme(){
    Get.changeThemeMode(_loadThemeFromBox()?ThemeMode.light:ThemeMode.dark);
    //above code returns false at first so we switch it to true
    _saveThemeToBox(!_loadThemeFromBox());
  }
}