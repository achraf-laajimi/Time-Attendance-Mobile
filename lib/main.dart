// lib/main.dart (update)
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_out/provider/color_provider.dart';
import 'package:in_out/provider/language_provider.dart';
import 'package:in_out/provider/profile_provider.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:in_out/utils/app_initializer.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'auth/auth_wrapper.dart';
import 'localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final userId = await AuthService.getCurrentUserId();

  final userSettingsProvider = UserSettingsProvider();
  await userSettingsProvider.initialize(userId);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserSettingsProvider>.value(
          value: userSettingsProvider,
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (context) => LanguageProvider(),
        ),
        ChangeNotifierProvider<ColorProvider>(
          create: (context) => ColorProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(),
        ),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    AppInitializer.handleHotReload(context);
    return Consumer2<LanguageProvider, UserSettingsProvider>(
      builder: (context, languageProvider, userSettingsProvider, child) {
        final settings = userSettingsProvider.currentSettings;
        final lightTheme = ThemeData(
          brightness: Brightness.light,
          primarySwatch: _createMaterialColor(settings.primaryColor),
          colorScheme: ColorScheme.light(
            primary: settings.primaryColor,
            secondary: settings.secondaryColor,
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: settings.primaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: settings.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: settings.primaryColor),
            ),
          ),
        );

        final darkTheme = ThemeData(
          brightness: Brightness.dark,
          primarySwatch: _createMaterialColor(settings.primaryColor),
          colorScheme: ColorScheme.dark(
            primary: settings.primaryColor,
            secondary: settings.secondaryColor,
          ),
          cardColor: const Color(0xFF1E1E1E),
          scaffoldBackgroundColor: const Color(0xFF121212),
          buttonTheme: ButtonThemeData(
            buttonColor: settings.primaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: settings.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2C2C2C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: settings.primaryColor),
            ),
          ),
        );
        AdaptiveThemeMode initialThemeMode;
        switch (settings.themeMode) {
          case 'dark':
            initialThemeMode = AdaptiveThemeMode.dark;
            break;
          case 'light':
            initialThemeMode = AdaptiveThemeMode.light;
            break;
          default:
            initialThemeMode = savedThemeMode ?? AdaptiveThemeMode.system;
        }
        final userSettings = Provider.of<UserSettingsProvider>(context);
        final appTheme = savedThemeMode ?? AdaptiveThemeMode.light;

        // Initialize profile provider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
          profileProvider.initialize();
        });
        return AdaptiveTheme(
          light: ThemeData(
            primaryColor: userSettings.currentSettings.primaryColor,
            colorScheme: ColorScheme.light(
              primary: userSettings.currentSettings.primaryColor,
              secondary: userSettings.currentSettings.secondaryColor,
            ),
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          ),
          dark: ThemeData(
            primaryColor: userSettings.currentSettings.primaryColor,
            colorScheme: ColorScheme.dark(
              primary: userSettings.currentSettings.primaryColor,
              secondary: userSettings.currentSettings.secondaryColor,
            ),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          ),
          initial: appTheme,
          builder: (theme, darkTheme) => MaterialApp(
            title: 'In & Out',
            theme: theme,
            darkTheme: darkTheme,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
            ],
            locale: Locale(userSettings.currentSettings.language),
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
          ),
        );
      },
    );
  }
  MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}