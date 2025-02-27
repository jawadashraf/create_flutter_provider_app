import 'package:flutter/material.dart';
import 'package:noteapp/ui/auth/register_screen.dart';
import 'package:noteapp/ui/auth/sign_in_screen.dart';
import 'package:noteapp/ui/home/geo_locator.dart';
import 'package:noteapp/ui/masjid/create_edit_masjid_screen.dart';
import 'package:noteapp/ui/masjid/masjids_screen.dart';
import 'package:noteapp/ui/masjid/salah_times_screen.dart';
import 'package:noteapp/ui/setting/setting_screen.dart';
import 'package:noteapp/ui/splash/splash_screen.dart';
import 'package:noteapp/ui/todo/create_edit_todo_screen.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiate this object

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String setting = '/setting';
  static const String create_edit_todo = '/create_edit_todo';
  static const String create_edit_masjid = '/create_edit_masjid';
  static const String salah_times = '/salah_times';
  static const String geo_locator = '/geo_locator';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => SignInScreen(),
    register: (BuildContext context) => RegisterScreen(),
    home: (BuildContext context) => MasjidsScreen(), //TodosScreen(),
    setting: (BuildContext context) => SettingScreen(),
    create_edit_todo: (BuildContext context) => CreateEditTodoScreen(),
    create_edit_masjid: (BuildContext context) => CreateEditMasjidScreen(),
    salah_times: (BuildContext context) =>
        SalahTimesScreen(title: 'Prayer Times'),
    geo_locator: (BuildContext context) => GeolocatorWidget(),
  };
}
