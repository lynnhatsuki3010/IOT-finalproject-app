import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'providers/home_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/device_provider.dart';
import 'providers/social_auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => SocialAuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smartify',

            /// 🌙 Theme
            theme: themeProvider.lightTheme.copyWith(
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'Inter',
                  ),
            ),
            darkTheme: themeProvider.darkTheme.copyWith(
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'Inter',
                  ),
            ),
            themeMode: themeProvider.themeMode,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
