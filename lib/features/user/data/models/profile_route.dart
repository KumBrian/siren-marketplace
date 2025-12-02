import 'package:flutter/material.dart';

class ProfileRoute {
  final IconData? icon;
  final String title;
  final String? route;
  final Widget? trailing;
  final String? subRoute;
  final String? userId;

  const ProfileRoute({
    this.icon,
    required this.title,
    this.route,
    this.trailing,
    this.subRoute,
    this.userId,
  });
}
