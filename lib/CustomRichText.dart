// NOTE: thanks to 'bytedance - limengyun2008' providing the idea
// NOTE: github: 'https://github.com/bytedance/RealRichText'

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'CustomImageSpan.dart';
import 'CustomRichTextWrapper.dart';

class CustomRichText extends Text {
  final List<TextSpan> textSpanList;

  CustomRichText(
    this.textSpanList, {
    Key key,
    TextStyle style,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int maxLines,
    Locale locale,
  }) : super(
    "",
    style: style,
    textAlign: textAlign,
    textDirection: textDirection,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    locale: locale,
  );

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = style;
    if (style == null || style.inherit)
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    if (MediaQuery.boldTextOverride(context))
      effectiveTextStyle = effectiveTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));

    TextSpan textSpan = TextSpan(
      style: effectiveTextStyle,
      text: "",
      children: textSpanList,
    );

    // pass the context to CustomImageSpan to create a ImageConfiguration
    textSpan.children.forEach((f) {
      if (f is CustomImageSpan) {
        f.updateImageConfiguration(context, imageWidth: effectiveTextStyle.fontSize, imageHeight: effectiveTextStyle.fontSize);
      }
    });

    Widget result = CustomRichTextWrapper(
      textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textDirection: textDirection, // RichText uses Directionality.of to obtain a default if this is null.
      locale: locale, // RichText uses Localizations.localeOf to obtain a default if this is null
      softWrap: softWrap ?? defaultTextStyle.softWrap,
      overflow: overflow ?? defaultTextStyle.overflow,
      textScaleFactor: textScaleFactor ?? MediaQuery.textScaleFactorOf(context),
      maxLines: maxLines ?? defaultTextStyle.maxLines,
      text: textSpan
    );

    if (semanticsLabel != null) {
      result = Semantics(
        textDirection: textDirection,
        label: semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }
    return result;
  }
}