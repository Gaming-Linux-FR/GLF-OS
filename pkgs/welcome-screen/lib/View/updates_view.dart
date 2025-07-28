import 'package:flutter/material.dart';
import 'package:glfos_welcome_screen/View/Shared/sharedmarkdown_view.dart';

class UpdatesView extends StatefulWidget {
  const UpdatesView({super.key});

  final String titleKey = 'page_updates_title';
  final String bodyKey = 'page_updates_body';

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  @override
  Widget build(BuildContext context) {
    return SharedMarkdownView(
        titleKey: widget.titleKey,
        bodyKey: widget.bodyKey,
        image: 'assets/images/updates.png',
        command: '');
  }
}
