import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final bool centerTitle;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? drawer;

  const ResponsiveScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.appBar,
    this.centerTitle = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: ResponsiveLayout.buildResponsiveWrapper(
        context: context,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      drawer: drawer,
    );
  }
}