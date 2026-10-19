import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double h;
  final double? w;
  final String images;
  final double borderRadius;
  final Color? backgroundColor;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.h = 120,
    this.w = 120,
    required this.images,
    this.borderRadius = 0,
    this.backgroundColor,
    this.fit = .contain,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(images, height: h, width: w, fit: fit);

    if (borderRadius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    if (backgroundColor != null || borderRadius > 0) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: image,
      );
    }

    return image;
  }
}
