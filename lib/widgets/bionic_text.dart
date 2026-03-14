import 'package:flutter/material.dart';

class BionicText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool enabled;
  final int? maxLines;
  final TextOverflow? overflow;

  const BionicText({
    super.key,
    required this.text,
    required this.style,
    this.enabled = true,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || text.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final words = text.split(' ');
    final spans = <TextSpan>[];

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) continue;

      // Calculate fixation point (roughly first 40-50% of the word)
      final fixationLength = (word.length / 2).ceil();
      final fixation = word.substring(0, fixationLength);
      final rest = word.substring(fixationLength);

      spans.add(TextSpan(
        text: fixation,
        style: style.copyWith(fontWeight: FontWeight.bold),
      ));
      spans.add(TextSpan(
        text: rest,
        style: style.copyWith(fontWeight: FontWeight.normal),
      ));

      // Add space after word (except for the last word)
      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: style));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
