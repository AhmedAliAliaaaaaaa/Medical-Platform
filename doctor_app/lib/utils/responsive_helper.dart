import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Get screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  // Check if mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  // Check if tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  // Check if desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  // Get responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.all(24);
      case ScreenType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  // Get responsive card padding
  static EdgeInsets getCardPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.all(20);
      case ScreenType.desktop:
        return const EdgeInsets.all(24);
    }
  }

  // Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing;
      case ScreenType.tablet:
        return baseSpacing * 1.2;
      case ScreenType.desktop:
        return baseSpacing * 1.4;
    }
  }

  // Get responsive font size
  static double getFontSize(BuildContext context, double baseFontSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.desktop:
        return baseFontSize * 1.2;
    }
  }

  // Get responsive icon size
  static double getIconSize(BuildContext context, double baseIconSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseIconSize;
      case ScreenType.tablet:
        return baseIconSize * 1.2;
      case ScreenType.desktop:
        return baseIconSize * 1.4;
    }
  }

  // Get responsive border radius
  static double getBorderRadius(BuildContext context, double baseBorderRadius) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseBorderRadius;
      case ScreenType.tablet:
        return baseBorderRadius * 1.1;
      case ScreenType.desktop:
        return baseBorderRadius * 1.2;
    }
  }

  // Get responsive card height
  static double getCardHeight(BuildContext context, double baseHeight) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseHeight;
      case ScreenType.tablet:
        return baseHeight * 1.1;
      case ScreenType.desktop:
        return baseHeight * 1.2;
    }
  }

  // Get max width constraints for content
  static BoxConstraints getMaxWidthConstraints(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const BoxConstraints(maxWidth: double.infinity);
      case ScreenType.tablet:
        return const BoxConstraints(maxWidth: 800);
      case ScreenType.desktop:
        return const BoxConstraints(maxWidth: 1200);
    }
  }

  // Get grid cross axis count
  static int getGridCrossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  // Get responsive aspect ratio
  static double getAspectRatio(
    BuildContext context, {
    double mobile = 1.2,
    double tablet = 1.3,
    double desktop = 1.4,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  // Get responsive column count for layout
  static int getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  // Get responsive text style
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: getFontSize(context, baseFontSize),
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Get responsive button style
  static ButtonStyle getResponsiveButtonStyle(
    BuildContext context, {
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      padding: EdgeInsets.symmetric(
        horizontal: getSpacing(context, 24),
        vertical: getSpacing(context, 16),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getBorderRadius(context, 12)),
      ),
    );
  }

  // Get responsive card decoration
  static BoxDecoration getResponsiveCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(getBorderRadius(context, 16)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: getSpacing(context, 10),
          offset: Offset(0, getSpacing(context, 5)),
        ),
      ],
    );
  }

  // Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  // Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  // Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  // Get orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  // Check if portrait
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  // Check if landscape
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }
}

enum ScreenType { mobile, tablet, desktop }
