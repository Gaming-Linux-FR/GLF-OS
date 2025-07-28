import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/View/Shared/sharedmarkdown_view.dart';

class GamingView extends StatefulWidget {
  const GamingView({super.key});

  final String titleKey = 'page_gaming_title';
  final String bodyKey = 'page_gaming_body';

  @override
  State<GamingView> createState() => _GamingViewState();
}

class _GamingViewState extends State<GamingView> {
  @override
  Widget build(BuildContext context) {
    return SharedMarkdownView(
        titleKey: widget.titleKey,
        bodyKey: widget.bodyKey,
        image: 'assets/images/gaming.png',
        command: '');
  }
}
