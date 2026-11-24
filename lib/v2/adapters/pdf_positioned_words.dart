import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfPositionedWordAdapter {
  List<PositionedWord> extract(File pdfFile, {String? password}) {
    final document = PdfDocument(
      inputBytes: pdfFile.readAsBytesSync(),
      password: password,
    );
    try {
      final words = <PositionedWord>[];
      for (var pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        final lines = PdfTextExtractor(
          document,
        ).extractTextLines(startPageIndex: pageIndex, endPageIndex: pageIndex);
        for (final line in lines) {
          for (final word in line.wordCollection) {
            final bounds = word.bounds;
            words.add(
              PositionedWord(
                text: word.text,
                x: bounds.left,
                y: bounds.top,
                width: bounds.width,
                height: bounds.height,
                page: pageIndex,
              ),
            );
          }
        }
      }
      return words;
    } finally {
      document.dispose();
    }
  }
}
