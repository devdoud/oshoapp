import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:osho/utils/constants/colors.dart';

class OShimmerEffect extends StatelessWidget {
  const OShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.radius = 15,
    this.color,
  });

  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (Colors.white),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
