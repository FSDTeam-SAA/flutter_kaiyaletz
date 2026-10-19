import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double? w;
  final double? h;

  const Gap({super.key, this.w, this.h});

  /// Creates a horizontal gap with the specified width.
  factory Gap.w(double width) => Gap(w: width);

  /// Creates a vertical gap with the specified height.
  factory Gap.h(double height) => Gap(h: height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: w, height: h);
  }
}
