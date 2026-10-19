import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

/// Centralized application icons using the HugeIcons library.
/// All icons used across the app are referenced from this class.
class AppIcons {
  AppIcons._();

  // Navigation
  static const IconData http = HugeIcons.strokeRoundedLink01;
  static const IconData vpnSecurity = HugeIcons.strokeRoundedShield01;

  // Actions & Controls
  static const IconData play = HugeIcons.strokeRoundedPlayCircle02;
  static const IconData pause = HugeIcons.strokeRoundedPauseCircle;
  static const IconData stop = HugeIcons.strokeRoundedStopCircle;
  static const IconData start = HugeIcons.strokeRoundedPlay;
  static const IconData send = HugeIcons.strokeRoundedSent02;
  static const IconData copy = HugeIcons.strokeRoundedCopy01;
  static const IconData delete = HugeIcons.strokeRoundedDelete01;
  static const IconData clearAll = HugeIcons.strokeRoundedDelete02;
  static const IconData deselectAll = HugeIcons.strokeRoundedDeleteThrow;
  static const IconData close = HugeIcons.strokeRoundedCancel01;
  static const IconData clear = HugeIcons.strokeRoundedCancel01;
  static const IconData edit = HugeIcons.strokeRoundedNoteEdit;
  static const IconData sync = HugeIcons.strokeRoundedReload;
  static const IconData moreVert = HugeIcons.strokeRoundedMoreVerticalCircle01;
  static const IconData chevronRight = HugeIcons.strokeRoundedArrowRight01;

  // Search & Filters
  static const IconData search = HugeIcons.strokeRoundedSearch01;
  static const IconData searchEmpty = HugeIcons.strokeRoundedSearchRemove;
  static const IconData filter = HugeIcons.strokeRoundedFilterHorizontal;
  static const IconData filterActive = HugeIcons.strokeRoundedFilterAdd;

  // Network & Protocols
  static const IconData networkCheck = HugeIcons.strokeRoundedWifi01;
  static const IconData internet = HugeIcons.strokeRoundedInternet;
  static const IconData public = HugeIcons.strokeRoundedGlobe02;
  static const IconData connections = HugeIcons.strokeRoundedConnect;
  static const IconData layers = HugeIcons.strokeRoundedLayers01;
  static const IconData dataUsage = HugeIcons.strokeRoundedDatabase01;

  // Details & Inspector
  static const IconData overview = HugeIcons.strokeRoundedInformationCircle;
  static const IconData requestUpload = HugeIcons.strokeRoundedUpload01;
  static const IconData responseDownload = HugeIcons.strokeRoundedDownload01;
  static const IconData pcapExport = HugeIcons.strokeRoundedDownload01;
  static const IconData terminal = HugeIcons.strokeRoundedCode;
  static const IconData file = HugeIcons.strokeRoundedFile01;
  static const IconData time = HugeIcons.strokeRoundedClock01;

  // Apps & System
  static const IconData apps = HugeIcons.strokeRoundedGrid02;
  static const IconData android = HugeIcons.strokeRoundedAndroid;
  static const IconData device = HugeIcons.strokeRoundedSmartPhone01;
  static const IconData checkboxBlank = HugeIcons.strokeRoundedSquare;
}
