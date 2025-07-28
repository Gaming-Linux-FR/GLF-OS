import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/View/Shared/sharedmarkdown_view.dart';

class StudioView extends StatefulWidget {
  const StudioView({super.key});

  final String titleKey = 'page_studio_title';
  final String bodyKey = 'page_studio_body';

  @override
  State<StudioView> createState() => _StudioViewState();
}

class _StudioViewState extends State<StudioView> {
  @override
  Widget build(BuildContext context) {
    return SharedMarkdownView(
        titleKey: widget.titleKey,
        bodyKey: widget.bodyKey,
        image: 'assets/images/studio_128.png',
        command: '');
  }
}
