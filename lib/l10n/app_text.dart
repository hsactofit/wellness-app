// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../app_brand.dart';
import 'app_string_catalog.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const AppText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final localizedStyle = _localizedStyle(style, languageCode);
    final localizedSemantics = semanticsLabel == null
        ? null
        : AppStringCatalog.translate(semanticsLabel!, languageCode);
    if (data != null) {
      return Text(
        AppStringCatalog.translate(data!, languageCode),
        key: key,
        style: localizedStyle,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: localizedSemantics,
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return Text.rich(
      _translateSpan(textSpan!, languageCode),
      key: key,
      style: localizedStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: localizedSemantics,
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  TextStyle? _localizedStyle(TextStyle? source, String languageCode) {
    if (!AppBrand.isMednovations || languageCode == 'en') return source;
    final family = languageCode == 'hi'
        ? 'NotoSansDevanagari'
        : 'NotoSansKannada';
    return (source ?? const TextStyle()).copyWith(fontFamily: family);
  }

  InlineSpan _translateSpan(InlineSpan span, String languageCode) {
    if (span is! TextSpan) return span;
    return TextSpan(
      text: span.text == null
          ? null
          : AppStringCatalog.translate(span.text!, languageCode),
      children: span.children
          ?.map((child) => _translateSpan(child, languageCode))
          .toList(),
      style: _localizedStyle(span.style, languageCode),
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }
}

extension AppLocalizedString on String {
  String localized(BuildContext context) => AppStringCatalog.translate(
    this,
    Localizations.localeOf(context).languageCode,
  );
}
