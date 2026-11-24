# Known Issues

This file records defects and blockers that are intentionally not fixed in the
current task. "Becomes within scope" identifies the earliest task fence or
milestone where the item must be handled.

## KI-001: M-PESA paid-in column

- **Status:** Known defect in the current V1 M-PESA PDF parser.
- **Evidence:** The parser does not reliably capture the M-PESA "Paid In"
  column. This affects income/money-in extraction and therefore cannot be
  recorded as expenditure.
- **Out-of-scope until:** T1.6, the M-PESA rule and golden parity task.
- **Required handling:** T1.6 must ensure the v2 rule engine captures and
  reconciles Paid In correctly while V1 golden behavior is preserved.
- **Follow-up validation:** T5.4 should include the M-PESA fixtures in every
  signed-rule fixture check.
- **Fixture constraint:** Fix or test this only with the redacted PDFs under
  `test/fixtures/` and matching redacted CSV/OFX exports under
  `test/golden/`. Never add real transaction data.

## KI-002: V1 data preservation

- **Status:** Low priority. Few tester users used V1 and their databases remain
  on local devices.
- **Out-of-scope until:** T2.4 for the read-only migrator and T4.7 for owner-
  approved cutover.
- **Current limitation:** V1 databases are not actively migrated or backed up
  as part of the preflight work. No real-device database copy is required for
  parser or package tasks.
- **Required handling:** Before T4.7, validate T2.4 against an owner-approved
  copy of real V1 data. T4.7 must preserve the exact read-only V1 path,
  `budget_audit/db.sqlite`, and create the timestamped backup before migration.

## KI-003: Supabase project setup

- **Status:** Waiting for owner configuration.
- **Out-of-scope until:** T6.1 for server migrations and policy tests.
- **Required inputs:** The existing Supabase project plus a project URL and
  anonymous public key supplied as build-time defines.
- **Recommended workflow:** Use the Supabase dashboard and Supabase CLI together.
  The dashboard is useful for inspecting Auth, RLS, Storage, logs and environment
  settings; the CLI is useful for versioned migrations and repeatable local or CI
  setup.
- **Secrets:** Never commit the service-role key, database password or JWT
  secrets. The app must receive only `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## KI-004: Windows validation

- **Status:** Not executable on this Fedora/Linux host.
- **Out-of-scope until:** T4.7 and cutover/release validation.
- **Required handling:** Run `flutter analyze` and
  `flutter build windows --debug` in a clean Windows environment, then record
  the runner result before T4.7 completion or release.
- **Linux substitute:** A Linux debug build is useful extra validation, but it
  does not replace the Windows app gate.

## KI-005: Existing analyzer debt

- **Status:** The current analyzer baseline is not green.
- **Out-of-scope until:** An owner-approved baseline-cleanup task.
- **Required handling:** For tasks that do not change analyzer scope, report
  the issue delta in touched files. Do not falsely describe the existing
  analyzer debt as resolved.
