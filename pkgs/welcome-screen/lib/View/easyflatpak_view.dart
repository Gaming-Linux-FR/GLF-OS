import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/View/Shared/sharedmarkdown_view.dart';

class EasyflatpakView extends StatefulWidget {
  const EasyflatpakView({
    super.key,
  });

  final String titleKey = 'page_easyflatpak_title';
  final String bodyKey = 'page_easyflatpak_body';

  @override
  State<EasyflatpakView> createState() => _EasyflatpakViewState();
}

class _EasyflatpakViewState extends State<EasyflatpakView> {
  @override
  Widget build(BuildContext context) {
    return SharedMarkdownView(
        titleKey: widget.titleKey,
        bodyKey: widget.bodyKey,
        image: 'assets/images/easyflatpak_128.png',
        command: 'flatpak://org.dupot.easyflatpak');
  }
}
