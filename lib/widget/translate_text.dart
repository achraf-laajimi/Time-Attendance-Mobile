import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';

class TranslateText extends StatelessWidget {
  final String keyName;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslateText(
      this.keyName, {
        super.key,
        this.style,
        this.maxLines,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).getString(keyName),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}