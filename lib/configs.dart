import 'package:flutter/material.dart';

class Navigation {
  String label;
  String path;
  Icon icon;
  Icon activeIcon;

  Navigation(
      {required this.label,
      required this.path,
      required this.icon,
      required this.activeIcon});
}

class AppConfigs {
  static String appUrl = 'https://partnerapp.pito.vn/monan';

  static String sendbridAppId = 'D7E523B1-C189-4BAF-8C7A-253BA7ED366E';
}
