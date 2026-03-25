import 'package:flutter/material.dart';

class OCircularContainer extends StatelessWidget {
  const OCircularContainer({super.key, this.width, this.height, required this.radius, required this.padding, this.child, required this.backgroundColor, this.margin});

  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final EdgeInsets? margin;
  final Widget? child;
  final Color backgroundColor;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}