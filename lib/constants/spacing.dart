import 'package:flutter/material.dart';

/// Centralized application dimensions, spacings, paddings, and radii.
/// All layout dimensions used across the app are defined here for consistency
/// and effortless future UI modifications.
class AppSpacing {
  AppSpacing._();

  // ==========================================
  // NUMERIC SPACING CONSTANTS (SCALARS)
  // ==========================================
  static const double zero = 0.0;
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;

  // Specific scalar constants used in UI elements
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  //static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // ==========================================
  // SIZED BOX SPACERS - VERTICAL
  // ==========================================
  static const SizedBox verticalXxs = SizedBox(height: xxs);
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox vertical6 = SizedBox(height: space6);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox vertical10 = SizedBox(height: space10);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox vertical14 = SizedBox(height: space14);
  static const SizedBox verticalBase = SizedBox(height: base);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalHuge = SizedBox(height: huge);

  /// Helper factory for dynamic or custom vertical gaps
  static SizedBox vertical(double height) => SizedBox(height: height);

  // ==========================================
  // SIZED BOX SPACERS - HORIZONTAL
  // ==========================================
  static const SizedBox horizontalXxs = SizedBox(width: xxs);
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontal6 = SizedBox(width: space6);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontal10 = SizedBox(width: space10);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontal14 = SizedBox(width: space14);
  static const SizedBox horizontalBase = SizedBox(width: base);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
  static const SizedBox horizontalXxl = SizedBox(width: xxl);
  static const SizedBox horizontalHuge = SizedBox(width: huge);

  /// Helper factory for dynamic or custom horizontal gaps
  static SizedBox horizontal(double width) => SizedBox(width: width);

  // ==========================================
  // EDGE INSETS - ALL SIDES
  // ==========================================
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAll6 = EdgeInsets.all(space6);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAll10 = EdgeInsets.all(space10);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllBase = EdgeInsets.all(base);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingAllXxl = EdgeInsets.all(xxl);

  // ==========================================
  // EDGE INSETS - SYMMETRIC (HORIZONTAL)
  // ==========================================
  static const EdgeInsets paddingHXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingH10 = EdgeInsets.symmetric(horizontal: space10);
  static const EdgeInsets paddingHMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHBase = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets paddingHLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHXl = EdgeInsets.symmetric(horizontal: xl);

  // ==========================================
  // EDGE INSETS - SYMMETRIC (VERTICAL)
  // ==========================================
  static const EdgeInsets paddingVXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingV10 = EdgeInsets.symmetric(vertical: space10);
  static const EdgeInsets paddingVMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVBase = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets paddingVLg = EdgeInsets.symmetric(vertical: lg);

  // ==========================================
  // EDGE INSETS - COMPONENT PRESETS
  // ==========================================
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: base, vertical: md);
  static const EdgeInsets paddingCard = EdgeInsets.all(base);
  static const EdgeInsets paddingDialog = EdgeInsets.all(lg);
  static const EdgeInsets paddingBottomSheet = EdgeInsets.all(lg);
  static const EdgeInsets paddingTile = EdgeInsets.symmetric(horizontal: base, vertical: sm);
  static const EdgeInsets paddingChip = EdgeInsets.symmetric(horizontal: md, vertical: space6);
  static const EdgeInsets paddingBadge = EdgeInsets.symmetric(horizontal: sm, vertical: xs);

  // ==========================================
  // BORDER RADIUS SCALARS
  // ==========================================
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusBase = 10.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusRound = 999.0;

  // Radius objects
  static const Radius radiusCircularXs = Radius.circular(radiusXs);
  static const Radius radiusCircularSm = Radius.circular(radiusSm);
  static const Radius radiusCircularMd = Radius.circular(radiusMd);
  static const Radius radiusCircularBase = Radius.circular(radiusBase);
  static const Radius radiusCircularLg = Radius.circular(radiusLg);
  static const Radius radiusCircularXl = Radius.circular(radiusXl);
  static const Radius radiusCircularXxl = Radius.circular(radiusXxl);

  // BorderRadius objects
  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusBase = BorderRadius.circular(radiusBase);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusRound = BorderRadius.circular(radiusRound);

  // ==========================================
  // COMPONENT SIZES & ELEVATIONS
  // ==========================================
  static const double iconXs = 16.0;
  static const double iconSm = 18.0;
  static const double iconMd = 20.0;
  static const double iconBase = 24.0;
  static const double iconLg = 26.0;
  static const double iconXl = 32.0;

  static const double appLogoSize = 26.0;
  static const double buttonHeight = 48.0;
  static const double minTouchTarget = 44.0;
}
