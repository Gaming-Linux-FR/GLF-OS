import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/Api/localization_api.dart';
import 'package:glfos_welcome_screen/View/gaming_view.dart';
import 'package:glfos_welcome_screen/View/diskmanger_view.dart';
import 'package:glfos_welcome_screen/View/easyflatpak_view.dart';
import 'package:glfos_welcome_screen/View/home_view.dart';
import 'package:glfos_welcome_screen/View/studio_view.dart';
import 'package:glfos_welcome_screen/View/updates_view.dart';
import 'package:glfos_welcome_screen/View/help_view.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.themeNotifier});

  final ValueNotifier<ThemeMode> themeNotifier;

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  String stateLanguageSelected = LocalizationApi().languageCode;

  bool stateIsDebug = true;

  int? _currentIndex = 0;

  bool _showNextTime = true;

  @override
  void initState() {
    super.initState();

    if (kReleaseMode) {
      setState(() => stateIsDebug = false);
    }

    listController = ScrollController();
    settingsController = ScrollController();
    _flapController = FlapController();

    _flapController.addListener(() => setState(() {}));

    load();
  }

  void load() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath:
          Platform.environment['HOME']! + '/bin/Welcome_screen-x86_64.AppImage',

      // Set packageName parameter to support MSIX.
      packageName: 'org.dupot.glfos_welcome_screen',
    );

    bool shouldLaunchAtStartup = await launchAtStartup.isEnabled();

    setState(() {
      _showNextTime = shouldLaunchAtStartup;
    });
  }

  late ScrollController listController;
  late ScrollController settingsController;
  late FlapController _flapController;

  @override
  void dispose() {
    listController.dispose();
    settingsController.dispose();
    super.dispose();
  }

  void changeTheme() =>
      widget.themeNotifier.value = widget.themeNotifier.value == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;

  final List<String> options = LocalizationApi.languages();

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
        //flapController: _flapController,
        actions: AdwActions().windowManager,
        start: [
          AdwHeaderButton(
            icon: const Icon(Icons.nightlight_round, size: 15),
            onPressed: changeTheme,
          ),
        ],
        title: Text(LocalizationApi().tr('app_title')),
        flap: (isDrawer) => AdwSidebar(
              currentIndex: _currentIndex,
              isDrawer: false,
              children: [
                AdwSidebarItem(
                  leading: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/glf-logo_menu_dark.png'
                          : 'assets/images/glf-logo_menu.png'),
                  label: LocalizationApi().tr('menu_home'),
                ),
                AdwSidebarItem(
                  leading: Image.asset('assets/images/gaming_menu.png'),
                  label: LocalizationApi().tr('menu_gaming'),
                ),
                AdwSidebarItem(
                  leading: Image.asset('assets/images/studio_128_menu.png'),
                  label: LocalizationApi().tr('menu_studio'),
                ),
                AdwSidebarItem(
                  leading: Image.asset('assets/images/updates_menu.png'),
                  label: LocalizationApi().tr('menu_updates'),
                ),
                AdwSidebarItem(
                  leading: Image.asset('assets/images/diskmanager_menu.png'),
                  label: LocalizationApi().tr('menu_diskManager'),
                ),
                AdwSidebarItem(
                  leading: Image.asset('assets/images/easyflatpak_menu.png'),
                  label: LocalizationApi().tr('menu_easyflatpak'),
                ),
                AdwSidebarItem(
                  leading: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/help_menu_dark.png'
                          : 'assets/images/help_menu.png'),
                  label: LocalizationApi().tr('menu_help'),
                ),
              ],
              onSelected: (index) => setState(() => _currentIndex = index),
            ),
        body: Column(children: [
          Expanded(
              child: AdwViewStack(
            animationDuration: const Duration(milliseconds: 100),
            index: _currentIndex,
            children: [
              const HomeView(),
              const GamingView(),
              const StudioView(),
              const UpdatesView(),
              const DiskmanagerView(),
              const EasyflatpakView(),
              const HelpView(),
            ],
          )),
          const Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _showNextTime,
              onChanged: (value) async {
                if (value!) {
                  await launchAtStartup.enable();
                } else {
                  await launchAtStartup.disable();
                }

                setState(() {
                  _showNextTime = value;
                });
              },
              title: Text(LocalizationApi().tr('bottom_show_window_next_time')),
            ),
          ),
        ]));
  }
}
