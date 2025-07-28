import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/View/Shared/sharedmarkdown_view.dart';

class HelpView extends StatefulWidget {
  const HelpView({
    super.key,
  });

  final String titleKey = 'page_help_title';
  final String bodyKey = 'page_help_body';

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  @override
  Widget build(BuildContext context) {
    return SharedMarkdownView(
        titleKey: widget.titleKey,
        bodyKey: widget.bodyKey,
        image: Theme.of(context).brightness == Brightness.dark
            ? 'assets/images/help.png'
            : 'assets/images/help_dark.png',
        command: '');
  }
}
