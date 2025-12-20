import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? normalStyle;
  final TextStyle? highlightStyle;

  const HighlightText({
    super.key,
    required this.text,
    required this.query,
    this.normalStyle,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: normalStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: normalStyle);
    }

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style:
              highlightStyle ??
              const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: normalStyle ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
