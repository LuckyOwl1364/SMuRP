// This file inspired by: https://medium.com/@kashifmin/flutter-login-app-using-rest-api-and-sqflite-b4815aed2149

import 'package:flutter/material.dart';
import 'history.dart';
import 'main.dart';




final routes = {
  '/login':         (BuildContext context) => new LoginScreen(),
  '/history':         (BuildContext context) => new SpecificWords(),
  '/' :          (BuildContext context) => new LoginScreen(),
};