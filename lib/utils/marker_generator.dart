import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  static Future<BitmapDescriptor> createPriceMarker(
    String priceText, {
    bool isSelected = false,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    const double width = 200.0;
    const double height = 125.0;
    const double cornerRadius = 50.0;
    const double pointerWidth = 30.0;
    const double pointerHeight = 22.0;

    final Color bgColor = isSelected ? const Color(0xFF035E50) : Colors.white;
    final Color textColor = isSelected ? Colors.white : const Color(0xFF2C3E38);
    final Color borderColor =
        isSelected ? Colors.white : const Color(0xFFE0E0E0);

    final Path path = Path();
    final RRect rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, width, height - pointerHeight),
      const Radius.circular(cornerRadius),
    );
    path.addRRect(rrect);

    path.moveTo(width / 2 - pointerWidth / 2, height - pointerHeight);
    path.lineTo(width / 2, height);
    path.lineTo(width / 2 + pointerWidth / 2, height - pointerHeight);
    path.close();

    canvas.drawShadow(path, Colors.black45, 6.0, true);

    final Paint paint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawPath(path, borderPaint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: priceText,
      style: TextStyle(
        fontSize: 48.0,
        color: textColor,
        fontWeight: FontWeight.w800,
      ),
    );

    textPainter.layout();

    final double textX = (width - textPainter.width) / 2;
    final double textY = ((height - pointerHeight) - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(textX, textY));

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }
}
