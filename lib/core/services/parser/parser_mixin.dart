import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../models/client_models.dart';

mixin ParserMixin {
  /// Helper method to unlock a password-protected PDF
  ///
  /// Returns ValidationErrorType.none if successful
  /// Returns specific error type otherwise
  Future<ValidationErrorType> unlockPdf(File pdfFile, String? password) async {
    try {
      final doc = PdfDocument(
          inputBytes: pdfFile.readAsBytesSync(), password: password);
      doc.dispose();
      return ValidationErrorType.none;
    } catch (e) {
      // If the document fails to load:
      // 1. If password was provided, it's likely incorrect
      if (password != null && password.isNotEmpty) {
        return ValidationErrorType.passwordIncorrect;
      }
      // 2. If no password provided, it likely requires one
      return ValidationErrorType.passwordRequired;
    }
  }

  /// Parses an amount string to a double
  ///
  /// Handles:
  /// - Currency symbols (KES, $, £, etc.)
  /// - Thousand separators (commas)
  /// - Negative amounts (parentheses or minus sign)
  /// - Debit/credit indicators
  ///
  /// Returns null if amount cannot be parsed
  double? parseAmount(String amountString) {
    final cleaned = amountString.replaceAll(RegExp(r'[£KES\$\s,]'), '').trim();
    try {
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }
}
