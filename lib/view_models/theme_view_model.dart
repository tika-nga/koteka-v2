import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel([Object? unused]);

  ThemeMode get flutterMode => ThemeMode.light;
}
