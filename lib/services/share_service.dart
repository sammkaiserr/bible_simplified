import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import '../models/verse.dart';

class ShareService {
  /// Shares plain text representation of a verse.
  Future<void> shareText({
    required Verse verse,
    required String bookName,
  }) async {
    final text = '''
📖 $bookName ${verse.chapterNumber}:${verse.verseNumber}

[సాధారణ తెలుగు]
${verse.simpleText ?? verse.originalText}

[మూల గ్రంథం]
${verse.originalText}

~ Bible Simplified యాప్ నుండి పంచుకోబడింది
''';
    await Share.share(text, subject: '$bookName ${verse.chapterNumber}:${verse.verseNumber}');
  }

  /// Captures a RepaintBoundary widget as an image and shares it.
  Future<void> shareImage(GlobalKey boundaryKey, String fileName) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Request a high pixel ratio for clean typography rendering
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$fileName.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Bible Simplified యాప్ నుండి పంచుకోబడింది 📖',
      );
    } catch (e) {
      debugPrint('Error sharing image card: $e');
    }
  }
}
