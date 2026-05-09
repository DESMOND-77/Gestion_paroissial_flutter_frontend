import 'package:flutter/material.dart';

class ResponsiveTextWidget extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final double minFontSize;
  final int maxLines;

  const ResponsiveTextWidget({
    super.key,
    required this.text,
    this.maxFontSize = 40,
    this.minFontSize = 10,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate font size based on available width
        double calculatedFontSize = constraints.maxWidth / 10;

        // Clamp font size between min and max
        double fontSize = calculatedFontSize.clamp(minFontSize, maxFontSize);

        return Text(
          text,
          style: TextStyle(fontSize: fontSize),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
