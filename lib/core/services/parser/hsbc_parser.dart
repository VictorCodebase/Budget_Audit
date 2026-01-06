// lib/core/services/parser/hsbc_parser.dart

import 'dart:io';
import 'package:budget_audit/core/services/parser/parser_mixin.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/client_models.dart';
import 'parser_interface.dart';

/**
 * TODO: Issue:
 * I need to find a way to exclude the domuent's text elements that are not part of the table as they distrupt the parsing process.
 * I need to ensure that the transactions are accurately extracted
 * 
 */

/// Represents a word/text element with its position in the PDF
class PositionedTextElement {
  final String text;
  final double x;
  final double y;
  final double width;
  final double height;

  PositionedTextElement({
    required this.text,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get centerX => x + (width / 2);
  double get centerY => y + (height / 2);
  double get right => x + width;
  double get bottom => y + height;

  @override
  String toString() => 'Element(text: "$text", x: $x, y: $y, w: $width)';
}

/// Represents a detected column in the statement
class ColumnDefinition {
  final String name;
  final double xStart;
  final double xEnd;
  final double centerX;

  ColumnDefinition({
    required this.name,
    required this.xStart,
    required this.xEnd,
  }) : centerX = (xStart + xEnd) / 2;

  bool contains(double x) => x >= xStart && x <= xEnd;

  double distanceFrom(double x) {
    if (x < xStart) return xStart - x;
    if (x > xEnd) return x - xEnd;
    return 0;
  }

  @override
  String toString() => 'Column($name: $xStart-$xEnd)';
}

/// Groups elements that belong together on the same row
class RowGroup {
  final List<PositionedTextElement> elements;
  final double y;
  final double height;

  RowGroup(this.elements, this.y, this.height);

  double get bottom => y + height;

  /// Get all elements in a specific column
  List<PositionedTextElement> elementsInColumn(ColumnDefinition col) {
    return elements.where((e) => col.contains(e.centerX)).toList();
  }

  /// Get concatenated text from a column
  String textInColumn(ColumnDefinition col) {
    final colElements = elementsInColumn(col);
    colElements.sort((a, b) => a.x.compareTo(b.x));
    return colElements.map((e) => e.text).join(' ');
  }

  @override
  String toString() => 'Row(y: $y, elements: ${elements.length})';
}

/// Parser for HSBC bank statements using word-level text extraction
class HSBCParser with ParserMixin implements StatementParser {
  final uuid = const Uuid();

  // Tunable thresholds
  static const double verticalRowThreshold =
      5.0; // Y-distance to group as same row
  static const double columnXTolerance =
      30.0; // X-distance for column boundaries
  static const double minColumnWidth = 40.0; // Minimum column width

  @override
  FinancialInstitution get institution => FinancialInstitution.hsbc;

  /// Extract individual words with position information from PDF
  /// Uses extractTextLines() then accesses wordCollection for each line
  List<PositionedTextElement> _extractTextElements(PdfDocument document) {
    final allElements = <PositionedTextElement>[];

    for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      // Extract text lines first
      final List<TextLine> lines = extractor.extractTextLines(
        startPageIndex: pageIndex,
        endPageIndex: pageIndex,
      );

      // Then extract words from each line
      for (final line in lines) {
        final List<TextWord> words = line.wordCollection;

        for (final word in words) {
          if (word.text.trim().isEmpty) continue;

          allElements.add(PositionedTextElement(
            text: word.text.trim(),
            x: word.bounds.left,
            y: word.bounds.top,
            width: word.bounds.width,
            height: word.bounds.height,
          ));
        }
      }
    }

    return allElements;
  }

  /// Filter elements to only include the transaction table region
  /// Removes header fluff and footer text for cleaner parsing
  List<PositionedTextElement> _filterToTransactionTable(
    List<PositionedTextElement> elements,
  ) {
    if (elements.isEmpty) return [];

    // Find table start markers
    int? tableStartIndex;
    int? tableEndIndex;

    for (int i = 0; i < elements.length; i++) {
      final text = elements[i].text;
      final textLower = text.toLowerCase();

      // Look for table start indicators
      if (tableStartIndex == null) {
        // Common HSBC table headers
        if (textLower == 'date' ||
            text.contains('Charitable Bank Account') ||
            text.contains('Payment type and details')) {
          // Scan forward to confirm this is the actual table
          final next20 = elements
              .skip(i)
              .take(20)
              .map((e) => e.text.toLowerCase())
              .join(' ');

          if (next20.contains('paid') && next20.contains('balance')) {
            tableStartIndex = i;
            print('Found table start at element $i: "$text"');
          }
        }
      }

      // Look for table end markers
      if (tableStartIndex != null && tableEndIndex == null) {
        if (text.contains('BALANCE CARRIED FORWARD') ||
            text.contains('BALANCE BROUGHT FORWARD') ||
            textLower.contains('business banking customers') ||
            textLower.contains('lost and stolen cards')) {
          tableEndIndex = i;
          print('Found table end at element $i: "$text"');
          break;
        }
      }
    }

    // If we found boundaries, extract just that region
    if (tableStartIndex != null) {
      final end = tableEndIndex ?? elements.length;
      final filtered = elements.sublist(tableStartIndex, end);
      print(
          'Filtered table: ${filtered.length} elements (from ${elements.length} total)');
      return filtered;
    }

    // Fallback: return all elements if we can't find boundaries
    print('WARNING: Could not find table boundaries, using all elements');
    return elements;
  }

  /// Group elements into rows based on Y-coordinate proximity
  List<RowGroup> _groupElementsIntoRows(List<PositionedTextElement> elements) {
    if (elements.isEmpty) return [];

    // Sort by Y coordinate first
    final sorted = List<PositionedTextElement>.from(elements)
      ..sort((a, b) => a.y.compareTo(b.y));

    final rows = <RowGroup>[];
    List<PositionedTextElement> currentRow = [sorted[0]];
    double currentY = sorted[0].y;
    double currentHeight = sorted[0].height;

    for (int i = 1; i < sorted.length; i++) {
      final element = sorted[i];

      // Check if this element is on the same row
      if ((element.y - currentY).abs() <= verticalRowThreshold) {
        currentRow.add(element);
        currentHeight =
            currentHeight > element.height ? currentHeight : element.height;
      } else {
        // New row starts
        if (currentRow.isNotEmpty) {
          // Sort elements in row by X coordinate
          currentRow.sort((a, b) => a.x.compareTo(b.x));
          rows.add(RowGroup(currentRow, currentY, currentHeight));
        }
        currentRow = [element];
        currentY = element.y;
        currentHeight = element.height;
      }
    }

    // Don't forget last row
    if (currentRow.isNotEmpty) {
      currentRow.sort((a, b) => a.x.compareTo(b.x));
      rows.add(RowGroup(currentRow, currentY, currentHeight));
    }

    return rows;
  }

  /// Detect column boundaries by analyzing header row and element X-positions
  Map<String, ColumnDefinition> _detectColumns(
    List<RowGroup> allRows,
    int headerRowIndex,
  ) {
    if (headerRowIndex >= allRows.length) return {};

    final columns = <String, ColumnDefinition>{};

    // Get header row elements
    final headerRow = allRows[headerRowIndex];
    final headerElements = List<PositionedTextElement>.from(headerRow.elements);

    // Find column headers and their positions
    PositionedTextElement? dateHeader;
    PositionedTextElement? paidOutHeader;
    PositionedTextElement? paidInHeader;
    PositionedTextElement? balanceHeader;

    for (final elem in headerElements) {
      final text = elem.text.toLowerCase();
      if (text.contains('date') && dateHeader == null) {
        dateHeader = elem;
      } else if ((text.contains('paid') && text.contains('out')) ||
          text.contains('paidout')) {
        paidOutHeader = elem;
      } else if ((text.contains('paid') && text.contains('in')) ||
          text.contains('paidin')) {
        paidInHeader = elem;
      } else if (text.contains('balance')) {
        balanceHeader = elem;
      }
    }

    // Check adjacent elements for multi-word headers (e.g., "Paid" "out")
    for (int i = 0; i < headerElements.length - 1; i++) {
      final current = headerElements[i].text.toLowerCase();
      final next = headerElements[i + 1].text.toLowerCase();

      if (current == 'paid' && next == 'out' && paidOutHeader == null) {
        paidOutHeader = headerElements[i];
      } else if (current == 'paid' && next == 'in' && paidInHeader == null) {
        paidInHeader = headerElements[i];
      }
    }

    print('Headers found:');
    print('  Date: $dateHeader');
    print('  Paid Out: $paidOutHeader');
    print('  Paid In: $paidInHeader');
    print('  Balance: $balanceHeader');

    // Define columns based on headers with reasonable boundaries
    if (dateHeader != null) {
      columns['date'] = ColumnDefinition(
        name: 'Date',
        xStart: dateHeader.x - 5,
        xEnd: dateHeader.right + 30,
      );
    }

    // Description column spans from end of date to start of amounts
    final descStart = (dateHeader?.right ?? 0) + 30;
    final descEnd = (paidOutHeader?.x ?? paidInHeader?.x ?? 400) - 10;
    if (descEnd > descStart) {
      columns['description'] = ColumnDefinition(
        name: 'Description',
        xStart: descStart,
        xEnd: descEnd,
      );
    }

    if (paidOutHeader != null) {
      columns['paidOut'] = ColumnDefinition(
        name: 'Paid Out',
        xStart: paidOutHeader.x - columnXTolerance,
        xEnd: paidOutHeader.right + columnXTolerance,
      );
    }

    if (paidInHeader != null) {
      columns['paidIn'] = ColumnDefinition(
        name: 'Paid In',
        xStart: paidInHeader.x - columnXTolerance,
        xEnd: paidInHeader.right + columnXTolerance,
      );
    }

    if (balanceHeader != null) {
      columns['balance'] = ColumnDefinition(
        name: 'Balance',
        xStart: balanceHeader.x - columnXTolerance,
        xEnd: balanceHeader.right + columnXTolerance,
      );
    }

    return columns;
  }

  /// Simple text extraction for validation (faster)
  String _extractSimpleText(PdfDocument document) {
    String fullText = '';
    for (int i = 0; i < document.pages.count; i++) {
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      fullText += extractor.extractText(startPageIndex: i, endPageIndex: i);
      fullText += '\n';
    }
    return fullText;
  }

  @override
  Future<ValidationResult> validateDocument(
    File pdfFile, {
    String? password,
  }) async {
    final missingCheckpoints = <String>[];

    try {
      // Validate PDF openability/security
      final unlockResult = await unlockPdf(pdfFile, password);
      if (unlockResult != ValidationErrorType.none) {
        return ValidationResult.failure(
          error: unlockResult == ValidationErrorType.passwordRequired
              ? 'Document is password protected'
              : 'Incorrect password',
          missing: ['PDF unlock failed'],
          type: unlockResult,
        );
      }

      final PdfDocument document = PdfDocument(
        inputBytes: pdfFile.readAsBytesSync(),
        password: password,
      );

      final fullText = _extractSimpleText(document);

      // Check for HSBC branding
      if (!fullText.toUpperCase().contains('HSBC')) {
        document.dispose();
        missingCheckpoints.add('HSBC branding');
        return ValidationResult(
          canParse: false,
          errorMessage: 'Document does not appear to be an HSBC statement',
          missingCheckpoints: missingCheckpoints,
        );
      }

      final hasAccountSummary = fullText.contains('Account Summary');
      final hasYourStatement = fullText.contains('Your Statement');
      final hasBankAccountDetails = fullText.contains('Bank Account') ||
          fullText.contains('Account Name');

      final hasTransactionIndicators =
          (fullText.contains('Paid out') || fullText.contains('Paidout')) &&
              (fullText.contains('Paid in') || fullText.contains('Paidin')) &&
              (fullText.contains('Balance'));

      final hasDRCR = fullText.contains(' DR ') ||
          fullText.contains(' CR ') ||
          (fullText.contains('DR') && fullText.contains('CR'));

      if (!hasAccountSummary && !hasYourStatement) {
        missingCheckpoints.add('Statement header');
      }

      if (!hasBankAccountDetails) {
        missingCheckpoints.add('Account details section');
      }

      if (!hasTransactionIndicators && !hasDRCR) {
        missingCheckpoints.add('Transaction data (Paid out/Paid in or DR/CR)');
      }

      document.dispose();

      if (missingCheckpoints.isEmpty) {
        return ValidationResult(
          canParse: true,
          errorMessage: null,
          missingCheckpoints: [],
        );
      } else {
        return ValidationResult(
          canParse: false,
          errorMessage:
              'Missing required elements: ${missingCheckpoints.join(", ")}',
          missingCheckpoints: missingCheckpoints,
        );
      }
    } catch (e) {
      return ValidationResult(
        canParse: false,
        errorMessage: 'Error validating document: $e',
        missingCheckpoints: ['Document validation failed: $e'],
      );
    }
  }

  @override
  Future<ParseResult> parseDocument(
    File pdfFile,
    UploadedDocument documentMetadata, {
    String? password,
  }) async {
    try {
      final PdfDocument document = PdfDocument(
        inputBytes: pdfFile.readAsBytesSync(),
        password: password,
      );

      // Extract individual word elements
      final allElements = _extractTextElements(document);
      document.dispose();

      print('=====EXTRACTED ${allElements.length} TEXT ELEMENTS (WORDS)=====');

      // Filter to transaction table only (removes header/footer noise)
      final elements = _filterToTransactionTable(allElements);

      print('=====FILTERED TO ${elements.length} TABLE ELEMENTS=====');
      print('Sample (first 30):');
      for (int i = 0; i < (elements.length > 30 ? 30 : elements.length); i++) {
        print(elements[i]);
      }

      // Group elements into rows (now much cleaner!)
      final rows = _groupElementsIntoRows(elements);
      print('\n=====GROUPED INTO ${rows.length} ROWS=====');
      print('Sample (first 20 rows):');
      for (int i = 0; i < (rows.length > 20 ? 20 : rows.length); i++) {
        final row = rows[i];
        final rowText = row.elements.map((e) => e.text).join(' ');
        print('Row $i (y: ${row.y.toStringAsFixed(1)}): $rowText');
      }

      // Find table header and detect columns
      int headerIndex = _findTableHeaderRow(rows);
      if (headerIndex == -1) {
        return ParseResult(
          success: false,
          transactions: [],
          errorMessage: 'Could not find transaction table headers',
          document: documentMetadata,
        );
      }

      print('\n=====TABLE HEADER FOUND AT ROW $headerIndex=====');

      final columns = _detectColumns(rows, headerIndex);
      print('\n=====DETECTED COLUMNS=====');
      columns.forEach((key, col) => print('$key: $col'));

      // Parse transactions
      final transactions =
          _extractTransactionsFromRows(rows, columns, headerIndex);

      print('\n=====EXTRACTED ${transactions.length} TRANSACTIONS=====');
      print('Sample (first 10):');
      for (int i = 0;
          i < (transactions.length > 10 ? 10 : transactions.length);
          i++) {
        final txn = transactions[i];
        print(
            '${DateFormat('dd MMM yy').format(txn.date)}: ${txn.vendorName} - ${txn.amount.toStringAsFixed(2)}');
      }

      if (transactions.isEmpty) {
        return ParseResult(
          success: false,
          transactions: [],
          errorMessage: 'No transactions found in the document',
          document: documentMetadata,
        );
      }

      return ParseResult(
        success: true,
        transactions: transactions,
        errorMessage: null,
        document: documentMetadata,
      );
    } catch (e) {
      return ParseResult(
        success: false,
        transactions: [],
        errorMessage: 'Error parsing document: $e',
        document: documentMetadata,
      );
    }
  }

  /// Find the row index that contains the table headers
  int _findTableHeaderRow(List<RowGroup> rows) {
    for (int i = 0; i < rows.length; i++) {
      final rowText =
          rows[i].elements.map((e) => e.text.toLowerCase()).join(' ');

      if (rowText.contains('date') &&
          (rowText.contains('paid') || rowText.contains('description')) &&
          rowText.contains('balance')) {
        return i;
      }
    }
    return -1;
  }

  /// Extract transactions from rows using detected columns
  List<ParsedTransaction> _extractTransactionsFromRows(
    List<RowGroup> rows,
    Map<String, ColumnDefinition> columns,
    int headerIndex,
  ) {
    final transactions = <ParsedTransaction>[];
    final datePattern = RegExp(r'^\d{1,2}\s+[A-Za-z]{3}\s+\d{2,4}$');

    DateTime? currentDate;
    List<RowGroup> currentTransactionRows = [];

    // Start parsing after header row
    for (int i = headerIndex + 1; i < rows.length; i++) {
      final row = rows[i];

      // Check for end markers
      final rowText = row.elements.map((e) => e.text).join(' ');
      if (rowText.contains('BALANCE CARRIED FORWARD') ||
          rowText.contains('BALANCE BROUGHT FORWARD')) {
        continue;
      }

      // Check if this row starts with a date
      DateTime? rowDate;
      if (columns.containsKey('date')) {
        final dateText = row.textInColumn(columns['date']!);
        if (datePattern.hasMatch(dateText)) {
          rowDate = parseDate(dateText);
        }
      }

      if (rowDate != null) {
        // Process previous transaction
        if (currentDate != null && currentTransactionRows.isNotEmpty) {
          final transaction = _parseTransactionFromRows(
            currentDate,
            currentTransactionRows,
            columns,
          );
          if (transaction != null) {
            transactions.add(transaction);
          }
        }

        // Start new transaction
        currentDate = rowDate;
        currentTransactionRows = [row];
      } else if (currentDate != null) {
        // Continuation of current transaction
        currentTransactionRows.add(row);
      }
    }

    // Process last transaction
    if (currentDate != null && currentTransactionRows.isNotEmpty) {
      final transaction = _parseTransactionFromRows(
        currentDate,
        currentTransactionRows,
        columns,
      );
      if (transaction != null) {
        transactions.add(transaction);
      }
    }

    return transactions;
  }

  /// Parse a transaction from its associated rows
  ParsedTransaction? _parseTransactionFromRows(
    DateTime date,
    List<RowGroup> rows,
    Map<String, ColumnDefinition> columns,
  ) {
    if (rows.isEmpty) return null;

    // Extract description
    String description = '';
    if (columns.containsKey('description')) {
      final descParts =
          rows.map((r) => r.textInColumn(columns['description']!)).toList();
      description = descParts.where((s) => s.isNotEmpty).join(' ').trim();
    }

    // If no description column detected, try to extract from all elements
    if (description.isEmpty) {
      final allText =
          rows.expand((r) => r.elements).map((e) => e.text).join(' ');
      description = allText
          .replaceFirst(RegExp(r'^\d{1,2}\s+[A-Za-z]{3}\s+\d{2,4}'), '')
          .trim();
    }

    // Determine transaction type (DR/CR)
    final allText = rows.expand((r) => r.elements).map((e) => e.text).join(' ');
    final isDR = allText.contains(' DR ') || allText.contains('DR');
    final isCR = allText.contains(' CR ') || allText.contains('CR');

    if (!isDR && !isCR) return null;

    // Extract amount from appropriate column
    double? amount;

    if (isDR && columns.containsKey('paidOut')) {
      amount = _extractAmountFromColumn(rows, columns['paidOut']!);
    } else if (isCR && columns.containsKey('paidIn')) {
      amount = _extractAmountFromColumn(rows, columns['paidIn']!);
    }

    // Fallback: search all elements for amount
    if (amount == null) {
      for (final row in rows) {
        for (final elem in row.elements) {
          final parsedAmount = parseAmount(elem.text);
          if (parsedAmount != null && parsedAmount > 0) {
            amount = parsedAmount;
            break;
          }
        }
        if (amount != null) break;
      }
    }

    if (amount == null || amount == 0) return null;

    // Clean description
    description = description
        .replaceAll(RegExp(r'\s+(DR|CR)\s+'), ' ')
        .replaceAll(RegExp(r'[\d,]+\.\d{2}'), '')
        .replaceAll(RegExp(r'[A-Z0-9]{10,}'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (description.isEmpty) description = 'Unknown';

    return ParsedTransaction(
      id: uuid.v4(),
      date: date,
      vendorName: normalizeVendorName(description),
      amount: isDR ? -amount.abs() : amount.abs(),
      ignoreTransaction: isCR,
      originalDescription: description,
      useMemory: true,
    );
  }

  /// Extract amount from a specific column
  double? _extractAmountFromColumn(
      List<RowGroup> rows, ColumnDefinition column) {
    for (final row in rows) {
      final colElements = row.elementsInColumn(column);
      for (final elem in colElements) {
        final amount = parseAmount(elem.text);
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }
    return null;
  }

  @override
  bool containsInstitutionMarkers(String pdfText) {
    return pdfText.toUpperCase().contains('HSBC');
  }

  @override
  List<List<String>> extractTableData(String pdfText) {
    return [];
  }

  @override
  String normalizeVendorName(String rawVendor) {
    String normalized = rawVendor.trim().replaceAll(RegExp(r'\s+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'^(BP|CR|DR)\s+'), '');
    normalized = normalized.replaceAll(RegExp(r'\b[A-Z0-9]{10,}\b'), '').trim();
    normalized = normalized
        .replaceAll(RegExp(r'\b(PAYMENT CHARGE|BIB BACS PAYMENT)\b'), '')
        .trim();
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized.isNotEmpty ? normalized : rawVendor;
  }

  @override
  DateTime? parseDate(String dateString) {
    try {
      dateString = dateString.trim();
      final formats = [
        DateFormat('dd MMM yy'),
        DateFormat('d MMM yy'),
        DateFormat('dd MMM yyyy'),
        DateFormat('d MMM yyyy'),
      ];

      for (final format in formats) {
        try {
          return format.parse(dateString);
        } catch (e) {
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
