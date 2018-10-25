import 'package:flutter/material.dart';
import 'history.dart';
import 'main.dart';

final routes = {
  '/login':         (BuildContext context) => new LoginScreen(),
  '/history':         (BuildContext context) => new SpecificWords(),
  '/' :          (BuildContext context) => new LoginScreen(),
};