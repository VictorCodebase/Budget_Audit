import 'package:logging/logging.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database.dart';
import '../models/models.dart' as models;

class TransactionService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("TransactionService");

  TransactionService(this._appDatabase);

  /// Fetch all known vendors
  Future<List<models.Vendor>> getAllVendors() async {
    try {
      final vendors = await _appDatabase.select(_appDatabase.vendors).get();
      return vendors
          .map((v) => models.Vendor(
                vendorId: v.vendorId,
                vendorName: v.vendorName,
              ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching vendors", e, st);
      return [];
    }
  }

  /// Fetch match history for a specific vendor
  Future<List<VendorMatchHistory>> getVendorMatchHistory(int vendorId) async {
    try {
      final query = _appDatabase.select(_appDatabase.vendorMatchHistories)
        ..where((tbl) => tbl.vendorId.equals(vendorId))
        ..orderBy([
          (t) => drift.OrderingTerm(
              expression: t.lastUsed, mode: drift.OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e, st) {
      _logger.severe(
          "Error fetching match history for vendor $vendorId", e, st);
      return [];
    }
  }

  /// Record a vendor match (create or update stats)
  Future<void> recordVendorMatch({
    required int vendorId,
    required int accountId,
    required int participantId,
  }) async {
    try {
      // Check if exists
      final existing =
          await (_appDatabase.select(_appDatabase.vendorMatchHistories)
                ..where((tbl) =>
                    tbl.vendorId.equals(vendorId) &
                    tbl.accountId.equals(accountId) &
                    tbl.participantId.equals(participantId)))
              .getSingleOrNull();

      if (existing != null) {
        // Update
        await (_appDatabase.update(_appDatabase.vendorMatchHistories)
              ..where(
                  (tbl) => tbl.vendorMatchId.equals(existing.vendorMatchId)))
            .write(VendorMatchHistoriesCompanion(
          useCount: drift.Value(existing.useCount + 1),
          lastUsed: drift.Value(DateTime.now()),
        ));
      } else {
        // Insert
        await _appDatabase.into(_appDatabase.vendorMatchHistories).insert(
              VendorMatchHistoriesCompanion.insert(
                vendorId: vendorId,
                accountId: accountId,
                participantId: participantId,
                lastUsed: DateTime.now(),
                useCount: const drift.Value(1),
              ),
            );
      }
    } catch (e, st) {
      _logger.severe("Error recording vendor match", e, st);
    }
  }

  /// Create a new vendor
  Future<int?> createVendor(String name) async {
    try {
      final id = await _appDatabase.into(_appDatabase.vendors).insert(
            VendorsCompanion.insert(vendorName: name),
          );
      return id;
    } catch (e, st) {
      _logger.severe("Error creating vendor $name", e, st);
      return null;
    }
  }
}
