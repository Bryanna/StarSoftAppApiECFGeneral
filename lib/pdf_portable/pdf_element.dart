/// Portable PDF element model for template-based rendering.
/// Keep it UI-agnostic and independent of Flutter UI.

enum PdfElementType {
  text,
  logo,
  line,
  rect,
}

class PdfElement {
  final PdfElementType type;
  final double x;
  final double y;
  final double width;
  final double height;

  // Text-specific
  final String? text;
  final double? fontSize;
  final bool bold;
  final String? align; // left, center, right

  // Colors in hex (e.g. #005285). Optional.
  final String? color;
  final String? backgroundColor;
  final String? borderColor;
  final double borderWidth;
  final double borderRadius;

  const PdfElement({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.text,
    this.fontSize,
    this.bold = false,
    this.align,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius = 0,
  });
}