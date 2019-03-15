import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'CustomRichText.dart';
import 'CustomImageSpan.dart';

// NOTE: example
// ```dart
// new Container(
//   child: new Center(
//     child: new InlineExpressionTextWidget(
//       'This is an example qq face: #newqqface0000_1#. And this is another example qq face: #newqqface0000_1#. This is end Text',
//       textStyle: new TextStyle(
//         fontSize: 24.0,
//       ),
//     ),
//   ),
// ),
// ```

// NOTE: 行内表情文本控件
class InlineExpressionTextWidget extends StatelessWidget {
  InlineExpressionTextWidget(
    String inputString, {
    this.textStyle,
    this.maxLines,
    String imageUrl = 'assets/images/expression/',
    String imageType = '.png',
    String expressionRegExpString = r'#\w+#',
    this.overflow,
  }) {
    generateInlineExpressionTextList(inputString, effectiveTextStyle: this.textStyle);
  }

  InlineExpressionTextWidget.comment(
    String commentContent, {
    this.textStyle,
    this.maxLines,
    String commentFromName,
    String commentToName,
    TextStyle commentTextStyle,
    VoidCallback commentFromNameOnTap,
    VoidCallback commentToNameOnTap,
    String imageUrl = 'assets/images/expression/',
    String imageType = '.png',
    String expressionRegExpString = r'#\w+#',
    String splitByCommentToNameAndCommentContent = '：',
    this.overflow,
  }) {
    final String fontFamilyPingFangSCMedium = 'PingFang-SC-Medium';
    final String fontFamilyPingFangSCRegular = 'PingFang-SC-Regular';
    // NOTE: 
    final TextStyle usernameTextStyle = new TextStyle(
      color: new Color(0xFF5b8edb),
      fontFamily: fontFamilyPingFangSCMedium,
    );
    TextStyle commentFromNameEffectiveTextStyle = commentTextStyle;
    if (commentTextStyle == null || commentTextStyle.inherit) {
      commentFromNameEffectiveTextStyle = usernameTextStyle.merge(commentTextStyle);
    }
    TextStyle commentToNameEffectiveTextStyle = commentTextStyle;
    if (commentTextStyle == null || commentTextStyle.inherit) {
      commentToNameEffectiveTextStyle = usernameTextStyle.merge(commentTextStyle);
    }

    final TextStyle otherTextStyle = new TextStyle(
      color: new Color(0xFF252c41),
      fontFamily: fontFamilyPingFangSCRegular,
      // fontSize: 28.0,
    );
    TextStyle commentContentEffectiveTextStyle = commentTextStyle;
    if (commentTextStyle == null || commentTextStyle.inherit) {
      commentContentEffectiveTextStyle = otherTextStyle.merge(commentTextStyle);
    }

    // NOTE: comment from
    if (commentFromName != null) {
      textSpanList.add(new TextSpan(
        text: commentFromName,
        style: commentFromNameEffectiveTextStyle,
        recognizer: new TapGestureRecognizer()..onTap = commentFromNameOnTap ?? () {
          debugPrint('TEST: commentFromName.recognizer.onTap');
        },
      ));
    }
    // NOTE: comment to
    if (commentToName != null) {
      textSpanList.add(
        new TextSpan(
          text: (commentFromName == null ? '' : ' ') + '回复 ',
          style: commentContentEffectiveTextStyle,
        ),
      );
      textSpanList.add(new TextSpan(
        text: commentToName,
        style: commentToNameEffectiveTextStyle,
        recognizer: new TapGestureRecognizer()..onTap = commentToNameOnTap ?? () {
          debugPrint('TEST: commentToName.recognizer.onTap');
        },
      ));
    }
    if (splitByCommentToNameAndCommentContent != '') {
      this.textSpanList.add(new TextSpan(
        text: splitByCommentToNameAndCommentContent,
        style: commentContentEffectiveTextStyle,
      ));
    }

    generateInlineExpressionTextList(commentContent, effectiveTextStyle: commentContentEffectiveTextStyle);
  }

  final TextStyle textStyle;
  final List<TextSpan> textSpanList = new List<TextSpan>();
  final int maxLines;
  final TextOverflow overflow;

  void generateInlineExpressionTextList(String inputString, {
    TextStyle effectiveTextStyle,
    String expressionRegExpString = r'#\w+#',
    String imageUrl = 'assets/images/expression/',
    String imageType = '.png',
  }) {
    String swapString = inputString;
    RegExp expressionRegExp = new RegExp(expressionRegExpString);
    for (Match match in expressionRegExp.allMatches(inputString)) {
      // NOTE: 匹配表情字符串
      String expressionString = match.group(0);
      int index = swapString.indexOf(expressionString);
      // NOTE: 添加表情前的非空字符串
      String stringBeforeExpression = swapString.substring(0, index);
      if (stringBeforeExpression != '') {
        this.textSpanList.add(new TextSpan(text: stringBeforeExpression));
      }
      // NOTE: 添加自定义表情
      this.textSpanList.add(new CustomImageSpan(
        new AssetImage(imageUrl + expressionString.substring(1, expressionString.length-1) + imageType),
        imageWidth: this.textStyle?.fontSize ?? 14.0,
        imageHeight: this.textStyle?.fontSize ?? 14.0,
      ));
      // NOTE: 切分字符串
      swapString = swapString.substring(index + expressionString.length);
    }
    this.textSpanList.add(new TextSpan(
      text: swapString,
      style: effectiveTextStyle?.merge(this.textStyle),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new CustomRichText(
      textSpanList,
      style: textStyle,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
    );
  }
}