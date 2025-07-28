import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
      
  static Widget buildResponsiveWrapper({
    required BuildContext context,
    required Widget child,
    double maxWidthMobile = double.infinity,
    double maxWidthTablet = 700,
    double maxWidthDesktop = 1200,
  }) {
    final screenWidth = getScreenWidth(context);
    double maxWidth;
    
    if (isMobile(context)) {
      maxWidth = maxWidthMobile;
    } else if (isTablet(context)) {
      maxWidth = maxWidthTablet;
    } else {
      maxWidth = maxWidthDesktop;
    }
    
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }
}