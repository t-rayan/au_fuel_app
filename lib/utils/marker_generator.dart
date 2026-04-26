import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'brand_icons.dart';

class MarkerGenerator {
  // Static cache for SVG PictureInfo to avoid redundant asset loading/parsing
  static final Map<String, PictureInfo> _svgCache = {};

  static Future<BitmapDescriptor> createBrandMarker(
    String brand,
    String priceText, {
    bool isSelected = false,
    bool isCheapest = false,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Reverting to Teardrop with intended gap
    final double width = isCheapest ? 145.0 : 120.0;
    final double height = isCheapest ? 150.0 : 125.0;
    final double cornerRadius = width / 2;
    final double iconSize = isCheapest ? 60.0 : 50.0;
    final double tailWidth = isCheapest ? 42.0 : 36.0;
    final double tailHeight = isCheapest ? 26.0 : 22.0;
    final double spacing = 2.0;
    const double gap = 1.0; // Decreased gap for a tighter look

    final brandIcon = BrandIcons.getIconForBrand(brand);
    final Color brandColor = brandIcon.color;
    
    final Color bgColor = isCheapest 
        ? const Color(0xFFFFD700) 
        : (isSelected ? brandColor : Colors.white);
        
    final Color textColor = isCheapest 
        ? const Color(0xFF1E3D2F) 
        : (isSelected ? Colors.white : const Color(0xFF2C3E38));

    // 1. Draw the Teardrop Body (Separate Paths to maintain the gap)
    final Path circlePath = Path()..addOval(Rect.fromLTWH(0, 0, width, width));
    final Path tailPath = Path();
    tailPath.moveTo(width / 2 - tailWidth / 2, width + gap); 
    tailPath.lineTo(width / 2, width + gap + tailHeight);
    tailPath.lineTo(width / 2 + tailWidth / 2, width + gap);
    tailPath.close();

    final Paint paint = Paint()..color = bgColor;
    
    // Draw Shadow (Unified for depth)
    canvas.drawShadow(circlePath, Colors.black.withOpacity(0.2), 6.0, true);
    canvas.drawShadow(tailPath, Colors.black.withOpacity(0.2), 6.0, true);

    // Draw Fills
    canvas.drawPath(circlePath, paint);
    canvas.drawPath(tailPath, paint);

    // 2. Draw Borders (Separate to emphasize the gap)
    final Color borderColor = isSelected 
        ? Colors.white.withOpacity(0.9) 
        : (isCheapest ? const Color(0xFF1E3D2F).withOpacity(0.3) : Colors.black.withOpacity(0.1));
        
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCheapest ? 3.0 : 2.0;
    
    canvas.drawPath(circlePath, borderPaint);
    canvas.drawPath(tailPath, borderPaint);

    // 3. Setup Price Text (Bold and compact)
    final bool hasPrice = priceText.isNotEmpty && priceText != 'N/A';
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    
    if (hasPrice) {
      textPainter.text = TextSpan(
        text: priceText,
        style: TextStyle(
          fontSize: isCheapest ? 30.0 : 26.0,
          color: textColor,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
      );
      textPainter.layout();
    }

    // 3. Draw stacked content (Icon then Price)
    // We center within the circular head (width x width)
    final double finalIconSize = hasPrice ? iconSize : iconSize * 1.25;
    final double totalContentHeight = hasPrice ? (finalIconSize + spacing + textPainter.height) : finalIconSize;
    final double startY = (width - totalContentHeight) / 2;

    // A. Draw Icon
    try {
      PictureInfo pictureInfo;
      if (_svgCache.containsKey(brandIcon.assetPath)) {
        pictureInfo = _svgCache[brandIcon.assetPath]!;
      } else {
        pictureInfo = await vg.loadPicture(SvgAssetLoader(brandIcon.assetPath), null);
        _svgCache[brandIcon.assetPath] = pictureInfo;
      }
      
      canvas.save();
      
      final double logoX = (width - finalIconSize) / 2;
      final double logoY = startY;
      
      canvas.translate(logoX, logoY);
      final double scale = finalIconSize / (pictureInfo.size.width > pictureInfo.size.height ? pictureInfo.size.width : pictureInfo.size.height);
      
      final double offsetX = (finalIconSize - pictureInfo.size.width * scale) / 2;
      final double offsetY = (finalIconSize - pictureInfo.size.height * scale) / 2;
      canvas.translate(offsetX, offsetY);
      
      canvas.scale(scale, scale);
      canvas.drawPicture(pictureInfo.picture);
      canvas.restore();
    } catch (e) {
      debugPrint("Error drawing SVG: $e");
      final Paint fallbackPaint = Paint()..color = brandColor;
      canvas.drawCircle(Offset(width / 2, startY + finalIconSize / 2), finalIconSize / 2, fallbackPaint);
    }

    // B. Draw Price (Bottom part of the circle)
    if (hasPrice) {
      final double textX = (width - textPainter.width) / 2;
      final double textY = startY + finalIconSize + spacing;
      textPainter.paint(canvas, Offset(textX, textY));
    }

    // 4. Draw "BEST" Badge (Larger and more prominent)
    if (isCheapest) {
      final Paint badgePaint = Paint()..color = const Color(0xFF1E3D2F); // Dark Green badge
      const double badgeWidth = 85.0;
      const double badgeHeight = 28.0;
      final RRect badgeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(width - 55, -8, badgeWidth, badgeHeight),
        const Radius.circular(10),
      );
      canvas.drawRRect(badgeRect, badgePaint);

      final TextPainter badgeTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );
      badgeTextPainter.text = const TextSpan(
        text: 'CHEAPEST',
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFFD700), // Gold text
          letterSpacing: 0.5,
        ),
      );
      badgeTextPainter.layout();
      badgeTextPainter.paint(canvas, Offset(width - 55 + (badgeWidth - badgeTextPainter.width) / 2, -8 + (badgeHeight - badgeTextPainter.height) / 2));
    }

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      (width + gap + tailHeight).toInt(),
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  // Keep the old method for compatibility or as a fallback
  static Future<BitmapDescriptor> createPriceMarker(
    String priceText, {
    bool isSelected = false,
  }) async {
    return createBrandMarker('unknown', priceText, isSelected: isSelected);
  }
}
