import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/View/Shared/sharedmarkdown_view.dart';

class PowerusersView extends StatefulWidget {
  const PowerusersView({super.key});

  final String titleKey = 'page_powerusers_title';
  final String bodyKey = 'page_powerusers_body';

  @override
  State<PowerusersView> createState() => _PowerusersViewState();
}

class _PowerusersViewState extends State<PowerusersView> {
  @override
  Widget build(BuildContext context) {
    return SharedMarkdownView(
        titleKey: widget.titleKey,
        bodyKey: widget.bodyKey,
        image: '',
        command: '');
  }
}
