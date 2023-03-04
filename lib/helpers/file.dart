import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:printing/printing.dart';
import 'dart:ui' as ui;

Future<Uint8List?> captureImageBytes(GlobalKey key) async {
  RenderRepaintBoundary? boundary;
  if (key.currentContext != null) {
    boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary?;
  }
  if (boundary != null) {
    ui.Image? image = await boundary.toImage(pixelRatio: 3.0);
    if (image != null) {
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    }
  }
  return null;
}

Future<void> shareImageBytes(Uint8List bytes) async {
  try {
    await Printing.sharePdf(bytes: bytes, filename: 'invoice.png');
  } catch (e) {
    print(e);
  }
}
