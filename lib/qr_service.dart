import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:qr_flutter/qr_flutter.dart';

class QrService {
  static Future<Uint8List> qrPngBytes(
    String data, {
    double size = 220,
  }) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
    );

    final ui.Image img = await painter.toImage(size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to render QR PNG bytes');
    }
    return byteData.buffer.asUint8List();
  }
}
