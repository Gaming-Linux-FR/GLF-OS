import 'dart:async';

import 'package:adwaita/adwaita.dart';
import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/Api/localization_api.dart';
import 'package:glfos_welcome_screen/welcome_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.hide();

  await LocalizationApi().load('fr');

  const windowOptions = WindowOptions(
    size: Size(1000, 600),
    minimumSize: Size(800, 350),
    skipTaskbar: false,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Welcome screen',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();

      await windowManager.show();
      await windowManager.focus();
    }),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          builder: (context, child) {
            final virtualWindowFrame = VirtualWindowFrameInit();

            return virtualWindowFrame(context, child);
          },
          theme: AdwaitaThemeData.light(),
          darkTheme: AdwaitaThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: WelcomeScreen(themeNotifier: themeNotifier),
          themeMode: currentMode,
        );
      },
    );
  }
}
