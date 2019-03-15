// NOTE: thanks to 'bytedance - limengyun2008' providing the idea
// NOTE: github: 'https://github.com/bytedance/RealRichText'

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'CustomImageSpan.dart';

/// paint the image on the top of those CustomImageSpan's blank space
class CustomRealRichRenderParagraph extends RenderParagraph {
  CustomRealRichRenderParagraph(TextSpan text, {
    TextAlign textAlign,
    TextDirection textDirection,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    Locale locale,
  }) : super(
    text,
    textAlign: textAlign,
    textDirection: textDirection,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    locale: locale,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    // Here it is!
    paintImageSpan(context, offset);
  }

  @override
  void detach() {
    super.detach();
    text.children.forEach((textSpan) {
      if (textSpan is CustomImageSpan) {
        textSpan.imageResolver.stopListening();
      }
    });
  }

  @override
  void performLayout() {
    super.performLayout();
  }

  /// this method draws inline-image over blank text space.
  void paintImageSpan(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Rect bounds = offset & size;

    canvas.save();

    int textOffset = 0;
    text.children.forEach((textSpan) {
      if (textSpan is CustomImageSpan) {
        // this is the top-center point of the CustomImageSpan
        Offset offsetForCaret = getOffsetForCaret(
          TextPosition(offset: textOffset),
          bounds,
        );

        // found this is a overflowed image. ignore it
        if (textOffset != 0 && offsetForCaret.dx == 0 && offsetForCaret.dy == 0) {
          return;
        }

        // this is the top-left point of the CustomImageSpan.
        // Usually, offsetForCaret indicates the top-center offset
        // except the first text which is always (0, 0)
        Offset topLeftOffset = Offset(
          offset.dx + (textOffset == 0 ? 0 : offsetForCaret.dx) - (textOffset == 0 ? 0 : textSpan.width / 2),
          offset.dy + offsetForCaret.dy,
        );

        // if image is not ready: wait for async ImageInfo
        if (textSpan.imageResolver.image == null) {
          textSpan.imageResolver.resolve(() {
            if (owner == null || !owner.debugDoingPaint) {
              markNeedsPaint();
            }
          });
          return;
        }
        // else: just paint it. bottomCenter Alignment seems better...
        paintImage(
          canvas: canvas,
          rect: topLeftOffset & Size(textSpan.width, textSpan.height),
          image: textSpan.imageResolver.image,
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
        );
      }
      textOffset += textSpan.toPlainText().length;
    });

    canvas.restore();
  }
}

