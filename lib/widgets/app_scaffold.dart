import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  const AppScaffold({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF5F7),
      appBar: appBar,
      body: body,
    );
  }
}
