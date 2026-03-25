import 'package:flutter/material.dart';
import 'package:osho/utils/constants/sizes.dart';

class OSpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: OSizes.appBarHeight,
    left: OSizes.defaultPadding,
    right: OSizes.defaultPadding,
    bottom: OSizes.defaultPadding,
  );
}