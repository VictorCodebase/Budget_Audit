// import 'dart:io';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:intl/intl.dart';
// import '../../models/client_models.dart';
// import 'package:budget_audit/core/services/parser/parser_mixin.dart';
// import 'parser_interface.dart';

// class HsbcParser with ParserMixin implements StatementParser  {
//   @override
//   FinancialInstitution get institution => FinancialInstitution.hsbc;

//   // Regex for HSBC Date format: "02 Aug 24"
//   final RegExp _dateRegex = RegExp(r'^(\d{2}\s[A-Za-z]{3}\s\d{2})');

//   // Headers to detect document start
//   static const String _headerLineTrigger = 'Payment type and details';
//   static const String _startMarker = 'BALANCE BROUGHT FORWARD';
//   static const String _endMarker = 'BALANCE CARRIED FORWARD';

//   @override
//   Future<ValidationResult> validateDocument(File pdfFile,
//       {String? password}) async {
//     // 1. Try to unlock
//     final unlockResult = await unlockPdf(pdfFile, password);
//     if (unlockResult != ValidationErrorType.none) {
//       return ValidationResult.failure(
//         error: 'Could not unlock PDF',
//         type: unlockResult,
//       );
//     }

//     try {
//       final doc = PdfDocument(
//           inputBytes: pdfFile.readAsBytesSync(), password: password);
//       final text = PdfTextExtractor(doc)
//           .extractText(layoutText: true); // layoutText is CRITICAL
//       doc.dispose();

//       final missing = <String>[];

//       // HSBC checkpoints
//       if (!text.contains('HSBC')) missing.add('HSBC Logo/Text');
//       if (!text.contains(_headerLineTrigger))
//         missing.add('Transaction Table Header');
//       if (!text.contains('Paid out')) missing.add('Paid out Column');
//       if (!text.contains('Paid in')) missing.add('Paid in Column');

//       if (missing.isNotEmpty) {
//         return ValidationResult.failure(
//           error: 'Document missing key HSBC markers',
//           missing: missing,
//           type: ValidationErrorType.invalidFormat,
//         );
//       }

//       return const ValidationResult.success();
//     } catch (e) {
//       return ValidationResult.failure(
//           error: 'Unexpected validation error: $e',
//           type: ValidationErrorType.parsingFailed);
//     }
//   }

//   @override
//   Future<ParseResult> parseDocument(
//       File pdfFile, UploadedDocument documentMetadata,
//       {String? password}) async {
//     try {
//       final doc = PdfDocument(
//           inputBytes: pdfFile.readAsBytesSync(), password: password);
//       // layoutText: true preserves spaces, allowing us to detect columns by index
//       final fullText = PdfTextExtractor(doc).extractText(layoutText: true);
//       doc.dispose();

//       final lines = fullText.split('\n');
//       final transactions = <ParsedTransaction>[];

//       // Column Boundaries (Indices)
//       int? paidOutIndex;
//       int? paidInIndex;
//       int? balanceIndex;

//       bool parsingTransactions = false;
//       DateTime?
//           currentYearDate; // Use context or header to determine year if needed
//       DateTime? lastSeenDate;

//       // Temporary buffers for the current transaction being built
//       StringBuffer descriptionBuffer = StringBuffer();

//       for (var i = 0; i < lines.length; i++) {
//         String line = lines[i];

//         // 1. Calibration: Find headers to establish column zones
//         if (line.contains('Paid out') && line.contains('Paid in')) {
//           paidOutIndex = line.indexOf('Paid out');
//           paidInIndex = line.indexOf('Paid in');
//           balanceIndex = line.indexOf('Balance');
//           continue;
//         }

//         // 2. Start/Stop logic
//         if (line.contains(_startMarker)) {
//           parsingTransactions = true;
//           // Extract the opening balance date if needed, usually on this line
//           final dateMatch = _dateRegex.firstMatch(line.trim());
//           if (dateMatch != null) {
//             lastSeenDate = _parseDate(dateMatch.group(1)!);
//           }
//           continue;
//         }
//         if (line.contains(_endMarker)) {
//           parsingTransactions = false;
//           break;
//         }

//         if (!parsingTransactions) continue;
//         if (paidOutIndex == null || paidInIndex == null)
//           continue; // Safety check

//         // 3. Process Transaction Lines

//         // Check for new Date at start of line
//         final dateMatch = _dateRegex.firstMatch(line);
//         if (dateMatch != null) {
//           lastSeenDate = _parseDate(dateMatch.group(1)!);
//           // If we had a previous description buffering without an amount, clear it
//           // (This handles edge cases where descriptions bleed, but usually
//           // a new date means a hard stop for the previous entry)
//           descriptionBuffer.clear();
//         }

//         // Check for Amounts in columns
//         // We look for numbers roughly aligned with our headers
//         String? debitStr =
//             _extractTextAtColumn(line, paidOutIndex, paidInIndex);
//         String? creditStr =
//             _extractTextAtColumn(line, paidInIndex, balanceIndex);

//         double? debitAmt = parseAmount(debitStr);
//         double? creditAmt = parseAmount(creditStr);

//         // Extract Description Part (Left of Paid Out column)
//         // We take everything before the Paid Out column index
//         String lineDesc = line.length > paidOutIndex
//             ? line.substring(0, paidOutIndex).trim()
//             : line.trim();

//         // Clean the date out of the description if present
//         if (dateMatch != null) {
//           lineDesc = lineDesc.replaceFirst(dateMatch.group(1)!, '').trim();
//         }

//         // Accumulate description
//         if (lineDesc.isNotEmpty) {
//           if (descriptionBuffer.isNotEmpty) descriptionBuffer.write(' ');
//           descriptionBuffer.write(lineDesc);
//         }

//         // 4. Finalize Transaction if Amount Found
//         if (debitAmt != null || creditAmt != null) {
//           if (lastSeenDate == null) continue; // Should not happen in valid doc

//           final amount = debitAmt ?? creditAmt!;
//           // Negative for debit, Positive for credit
//           final finalAmount = debitAmt != null ? -amount : amount;

//           final fullDescription = descriptionBuffer.toString().trim();

//           transactions.add(ParsedTransaction(
//             id: DateTime.now().microsecondsSinceEpoch.toString(), // Temp ID
//             date: lastSeenDate,
//             vendorName: _cleanVendorName(fullDescription), // Heuristic cleaning
//             originalDescription: fullDescription,
//             amount: finalAmount,
//             matchStatus: MatchStatus.critical, // Default
//           ));

//           // Reset buffer for next transaction lines (e.g. comments after amount?)
//           // Usually HSBC puts comments BEFORE amount, so we clear here.
//           descriptionBuffer.clear();
//         }
//       }

//       return ParseResult(
//           success: true,
//           transactions: transactions,
//           document: documentMetadata);
//     } catch (e) {
//       return ParseResult(
//           success: false,
//           errorMessage: e.toString(),
//           transactions: [],
//           document: documentMetadata);
//     }
//   }

//   /// Extracts text strictly between two indices
//   String _extractTextAtColumn(String line, int startIdx, int? endIdx) {
//     if (line.length <= startIdx) return '';

//     final end = (endIdx != null && line.length > endIdx) ? endIdx : line.length;
//     // Safety buffer: sometimes layout shifts slightly left, so we look a bit before startIdx
//     // but for strictly formatted PDFs, strict indices work best.
//     // Let's grab the substring and trim.
//     try {
//       return line.substring(startIdx, end).trim();
//     } catch (e) {
//       return '';
//     }
//   }

//   DateTime _parseDate(String dateStr) {
//     // format: "02 Aug 24"
//     // You might need to adjust '24' to '2024' logic
//     try {
//       return DateFormat('dd MMM yy').parse(dateStr);
//     } catch (e) {
//       return DateTime.now(); // Fallback
//     }
//   }

//   String _cleanVendorName(String raw) {
//     // Remove common banking noise
//     var clean = raw;
//     clean = clean.replaceAll(RegExp(r'\b(BP|DR|CR|VIS)\b'), '');
//     clean = clean.replaceAll(RegExp(r'\s+'), ' ');
//     return clean.trim();
//   }
// }
