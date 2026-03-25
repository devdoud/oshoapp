
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:osho/utils/constants/colors.dart';

class OSkeleton extends StatelessWidget {
  const OSkeleton({
    super.key,
    required this.height,
    required this.width,
    this.radius = 16,
    this.color,
  });

  final double height;
  final double width;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: color ?? Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
