import 'package:flutter/material.dart';

class PdfElement {
  String type;
  double x;
  double y;
  double width;
  double height;
  String content;
  double fontSize;
  bool bold;
  Color color;
  Color backgroundColor;
  double borderRadius;

  PdfElement({
    required this.type,
    required this.x,
    required this.y,
    this.width = 0,
    this.height = 0,
    this.content = '',
    this.fontSize = 12,
    this.bold = false,
    this.color = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'content': content,
      'fontSize': fontSize,
      'bold': bold,
      'color': color.value,
      'backgroundColor': backgroundColor.value,
      'borderRadius': borderRadius,
    };
  }

  factory PdfElement.fromJson(Map<String, dynamic> json) {
    return PdfElement(
      type: json['type'] ?? '',
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      fontSize: (json['fontSize'] ?? 12).toDouble(),
      bold: json['bold'] ?? false,
      color: Color(json['color'] ?? Colors.black.value),
      backgroundColor: Color(
        json['backgroundColor'] ?? Colors.transparent.value,
      ),
      borderRadius: (json['borderRadius'] ?? 0).toDouble(),
    );
  }

  PdfElement copyWith({
    String? type,
    double? x,
    double? y,
    double? width,
    double? height,
    String? content,
    double? fontSize,
    bool? bold,
    Color? color,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return PdfElement(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      content: content ?? this.content,
      fontSize: fontSize ?? this.fontSize,
      bold: bold ?? this.bold,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
