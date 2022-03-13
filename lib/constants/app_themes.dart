import 'package:flutter/material.dart';
import 'package:noteapp/constants/app_font_family.dart';

class AppThemes {
  AppThemes._();

  static const String kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String kPermissionDeniedMessage = 'Location permission denied.';
  static const String kPermissionDeniedForeverMessage =
      'Location permission denied forever.';
  static const String kPermissionGrantedMessage =
      'Location permission granted.';

  static const String googleMapApiKey =
      'AIzaSyBd6F8oIHxOePYHPWlUo-duwtmu-E96__8';

  static const Color color3 = Color(0xFF1c1c1c);

  static const Color clockColorRed = Color(0xFFFF0000);
  static const Color clockColorGreen = Color(0xFF00FF00);

  //constants color range for light theme
  static const Color _lightPrimaryColor = Colors.black;
  static const Color _lightPrimaryVariantColor = Colors.white;
  static const Color _lightSecondaryColor = Colors.green;
  static const Color _lightOnPrimaryColor = Colors.black;
  static const Color _lightButtonPrimaryColor = Colors.orangeAccent;
  static const Color _lightAppBarColor = Colors.orangeAccent;
  static Color _lightIconColor = Colors.orangeAccent;
  static Color _lightSnackBarBackgroundErrorColor = Colors.redAccent;

  //text theme for light theme
  static final TextStyle _lightScreenHeadingTextStyle =
      TextStyle(fontSize: 20.0, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskNameTextStyle =
      TextStyle(fontSize: 16.0, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskDurationTextStyle =
      TextStyle(fontSize: 14.0, color: Colors.grey);
  static final TextStyle _lightScreenButtonTextStyle = TextStyle(
      fontSize: 14.0, color: _lightOnPrimaryColor, fontWeight: FontWeight.w500);
  static final TextStyle _lightScreenCaptionTextStyle = TextStyle(
      fontSize: 12.0, color: _lightAppBarColor, fontWeight: FontWeight.w100);

  static final TextTheme _lightTextTheme = TextTheme(
    headline5: _lightScreenHeadingTextStyle,
    bodyText1: _lightScreenTaskNameTextStyle,
    bodyText2: _lightScreenTaskDurationTextStyle,
    button: _lightScreenButtonTextStyle,
    headline6: _lightScreenTaskNameTextStyle,
    subtitle1: _lightScreenTaskNameTextStyle,
    caption: _lightScreenCaptionTextStyle,
  );

  //constants color range for dark theme
  static const Color _darkPrimaryColor = Colors.white;
  static const Color _darkPrimaryVariantColor = Colors.black;
  static const Color _darkSecondaryColor = Colors.white;
  static const Color _darkOnPrimaryColor = Colors.grey;
  static final Color _darkButtonPrimaryColor = Colors.green.shade800;
  static const Color _darkAppBarColor = Colors.black38;
  static Color _darkIconColor = Colors.green.shade800;
  static Color _darkSnackBarBackgroundErrorColor = Colors.redAccent;

  static const Color _timePickerAccentColor = Colors.orangeAccent;

  //text theme for dark theme
  static final TextStyle _darkScreenHeadingTextStyle =
      _lightScreenHeadingTextStyle.copyWith(color: _darkOnPrimaryColor);
  static final TextStyle _darkScreenTaskNameTextStyle =
      _lightScreenTaskNameTextStyle.copyWith(color: _darkOnPrimaryColor);
  static final TextStyle _darkScreenTaskDurationTextStyle =
      _lightScreenTaskDurationTextStyle;
  static final TextStyle _darkScreenButtonTextStyle = TextStyle(
      fontSize: 14.0, color: _darkOnPrimaryColor, fontWeight: FontWeight.w500);
  static final TextStyle _darkScreenCaptionTextStyle = TextStyle(
      fontSize: 12.0, color: _darkAppBarColor, fontWeight: FontWeight.w100);

  static final TextTheme _darkTextTheme = TextTheme(
    headline5: _darkScreenHeadingTextStyle,
    bodyText1: _darkScreenTaskNameTextStyle,
    bodyText2: _darkScreenTaskDurationTextStyle,
    button: _darkScreenButtonTextStyle,
    headline6: _darkScreenTaskNameTextStyle,
    subtitle1: _darkScreenTaskNameTextStyle,
    caption: _darkScreenCaptionTextStyle,
  );

  static final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.black87,
    primary: _darkButtonPrimaryColor,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  static BoxDecoration myLeftBoxDecoration() {
    return BoxDecoration(
      border: Border(
        left: BorderSide(
          //                   <--- left side
          color: Colors.orangeAccent,
          width: 1.0,
        ),
        top: BorderSide(
          //                    <--- top side
          color: Colors.orangeAccent,
          width: 1.0,
        ),
      ),
    );
  }

  static BoxDecoration myRightBoxDecoration() {
    return BoxDecoration(
      border: Border(
        right: BorderSide(
          //                   <--- left side
          color: Colors.orangeAccent,
          width: 1.0,
        ),
        bottom: BorderSide(
          //                    <--- top side
          color: Colors.orangeAccent,
          width: 1.0,
        ),
      ),
    );
  }

  //the light theme
  static final ThemeData lightTheme = ThemeData(
    fontFamily: AppFontFamily.productSans,
    scaffoldBackgroundColor: _lightPrimaryVariantColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightButtonPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      color: _lightAppBarColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
      textTheme: _lightTextTheme,
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryVariant: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
    ),
    snackBarTheme:
        SnackBarThemeData(backgroundColor: _lightSnackBarBackgroundErrorColor),
    iconTheme: IconThemeData(
      color: _lightIconColor,
    ),
    popupMenuTheme: PopupMenuThemeData(color: _lightAppBarColor),
    textTheme: _lightTextTheme,
    buttonTheme: ButtonThemeData(
        buttonColor: _lightButtonPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _lightPrimaryColor,
    inputDecorationTheme: InputDecorationTheme(
        fillColor: _lightPrimaryColor,
        labelStyle: TextStyle(
          color: _lightPrimaryColor,
        )),
  );

  //the dark theme
  static final ThemeData darkTheme = ThemeData(
      cardColor: Colors.black54,
      fontFamily: AppFontFamily.productSans,
      scaffoldBackgroundColor: _darkPrimaryVariantColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkButtonPrimaryColor,
      ),
      appBarTheme: AppBarTheme(
        color: _darkAppBarColor,
        iconTheme: IconThemeData(color: _darkOnPrimaryColor),
        textTheme: _darkTextTheme,
      ),
      colorScheme: ColorScheme.light(
        primary: _darkPrimaryColor,
        primaryVariant: _darkPrimaryVariantColor,
        secondary: _darkSecondaryColor,
        onPrimary: _darkOnPrimaryColor,
      ),
      errorColor: Colors.yellow,
      snackBarTheme:
          SnackBarThemeData(backgroundColor: _darkSnackBarBackgroundErrorColor),
      iconTheme: IconThemeData(
        color: _darkIconColor,
      ),
      popupMenuTheme: PopupMenuThemeData(color: _darkAppBarColor),
      textTheme: _darkTextTheme,
      buttonTheme: ButtonThemeData(
          buttonColor: _darkButtonPrimaryColor,
          textTheme: ButtonTextTheme.primary),
      elevatedButtonTheme: ElevatedButtonThemeData(style: raisedButtonStyle),
      unselectedWidgetColor: _darkPrimaryColor,
      inputDecorationTheme: InputDecorationTheme(
          fillColor: _darkPrimaryColor,
          labelStyle: TextStyle(
            color: _darkPrimaryColor,
          )),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.blueGrey,
        hourMinuteShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: _timePickerAccentColor, width: 4),
        ),
        dayPeriodBorderSide:
            const BorderSide(color: _timePickerAccentColor, width: 4),
        // dayPeriodColor: Colors.blueGrey.shade100,
        dayPeriodColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? _timePickerAccentColor
                : Colors.blueGrey.shade800),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: _timePickerAccentColor, width: 4),
        ),
        dayPeriodTextColor: Colors.white,
        dayPeriodShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: _timePickerAccentColor, width: 4),
        ),
        hourMinuteColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? _timePickerAccentColor
                : Colors.blueGrey.shade800),
        hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? Colors.white
                : _timePickerAccentColor),
        dialHandColor: Colors.blueGrey.shade700,
        dialBackgroundColor: Colors.blueGrey.shade800,
        hourMinuteTextStyle:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        dayPeriodTextStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        helpTextStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(0),
        ),
        dialTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? _timePickerAccentColor
                : Colors.white),
        entryModeIconColor: _timePickerAccentColor,
      ));
}
