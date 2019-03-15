// NOTE: thanks to 'bytedance - limengyun2008' providing the idea
// NOTE: github: 'https://github.com/bytedance/RealRichText'

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'CustomRichTextRenderParagraph.dart';

/// Just a subclass of RichText for overriding createRenderObject
/// to return a [RealRichRenderParagraph] object
///
/// No more special purpose.
class CustomRichTextWrapper extends RichText {
  const CustomRichTextWrapper({
    Key key,
    @required TextSpan text,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int maxLines,
    Locale locale,
  })  : assert(text != null),
    assert(textAlign != null),
    assert(softWrap != null),
    assert(overflow != null),
    assert(textScaleFactor != null),
    assert(maxLines == null || maxLines > 0),
    super(
      key: key,
      text: text,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      locale: locale,
    );

  @override
  RenderParagraph createRenderObject(BuildContext context) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    return CustomRealRichRenderParagraph(
      text,
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      locale: locale ?? Localizations.localeOf(context, nullOk: true),
    );
  }
}

