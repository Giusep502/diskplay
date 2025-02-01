import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  appBarTheme: const AppBarTheme(
    color: Colors.blue,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.blueGrey,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);
