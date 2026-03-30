// lib/core/services/parser/parser_factory.dart

import '../../models/client_models.dart';
import 'parser_interface.dart';
import 'hsbc_parser.dart';
import 'equity_parser.dart';
import 'mpesa_parser.dart';
import 'csv_parser.dart';
import 'ofx_parser.dart';

/// Factory class to create appropriate parser based on institution
class ParserFactory {
  /// Returns the appropriate parser for the given financial institution
  static StatementParser getParser(FinancialInstitution institution) {
    switch (institution) {
      case FinancialInstitution.equity:
        return EquityParser();
      case FinancialInstitution.mpesa:
        return MPesaParser();
      case FinancialInstitution.csv:
        return CSVParser();
      case FinancialInstitution.ofx:
        return OFXParser();
    } 
     // case FinancialInstitution.hsbc:
      //   return HsbcParser();
  }

  /// Returns a list of all supported institutions
  static List<FinancialInstitution> get supportedInstitutions {
    return FinancialInstitution.values;
  }

  /// Checks if a specific institution is supported
  static bool isSupported(FinancialInstitution institution) {
    return supportedInstitutions.contains(institution);
  }
}
