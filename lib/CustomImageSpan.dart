// NOTE: thanks to 'bytedance - limengyun2008' providing the idea
// NOTE: github: 'https://github.com/bytedance/RealRichText'

import 'dart:ui' as ui show Image;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CustomImageSpan extends TextSpan {
  final double imageWidth;
  final double imageHeight;
  final EdgeInsets margin;
  final ImageProvider imageProvider;
  final CustomImageResolver imageResolver;
  CustomImageSpan(
    this.imageProvider, {
    this.imageWidth = 14.0,
    this.imageHeight = 14.0,
    this.margin,
    double fontSize,
    GestureRecognizer recognizer,
  }) : imageResolver = CustomImageResolver(imageProvider),
  super(
    style: TextStyle(
      color: Colors.transparent,
      height: 1,
      letterSpacing: imageWidth + (margin == null ? 0 : margin.horizontal),
      fontSize: fontSize ?? (imageHeight / 1.15) + (margin == null ? 0 : margin.vertical),
    ),
    text: '\u200B',
    children: [],
    recognizer: recognizer,
  );

  void updateImageConfiguration(BuildContext context, {double imageWidth = 14.0, double imageHeight = 14.0}) {
    imageResolver.updateImageConfiguration(context, imageWidth, imageHeight);
  }

  double get width => imageWidth + (margin == null ? 0 : margin.horizontal);
  double get height => imageHeight + (margin == null ? 0 : margin.vertical);
}

typedef CustomImageResolverListener = void Function();

class CustomImageResolver {
  final ImageProvider imageProvider;

  ImageStream _imageStream;
  ImageConfiguration _imageConfiguration;
  ui.Image image;
  CustomImageResolverListener _listener;

  CustomImageResolver(this.imageProvider);

  /// set the ImageConfiguration from outside
  void updateImageConfiguration(BuildContext context, double width, double height) {
    _imageConfiguration = createLocalImageConfiguration(context, size: Size(width, height));
  }

  void resolve(CustomImageResolverListener listener) {
    assert(_imageConfiguration != null);

    final ImageStream oldImageStream = _imageStream;
    _imageStream = imageProvider.resolve(_imageConfiguration);
    assert(_imageStream != null);

    this._listener = listener;
    if (_imageStream.key != oldImageStream?.key) {
      oldImageStream?.removeListener(_handleImageChanged);
      _imageStream.addListener(_handleImageChanged);
    }
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    image = imageInfo.image;
    _listener?.call();
  }

  void stopListening() {
    _imageStream?.removeListener(_handleImageChanged);
  }
}
