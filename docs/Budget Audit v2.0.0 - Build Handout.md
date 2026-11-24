# Budget Audit v2.0.0 - Build Handout

This handout splits the v2 build into small numbered tasks. Do one task at a time, touch only the files that task allows, and stop when its done-when is true. If a task seems to need more than it allows, file a rescope note and wait. Do not widen the scope yourself.

## Preflight sanity check (2026-11-22)

These findings are binding prerequisites, not optional cleanup:

1. **Baseline state.** On the current project, `flutter test` passes (12 existing tests) and `flutter build linux --debug` succeeds. `flutter analyze` does not pass: it reports 251 existing issues, including warning-level issues and missing direct dependencies. No task may treat the existing analyzer debt as a green baseline. For tasks that do not change analyzer scope, require no additional issue count in the touched files. Strict zero-new-issue enforcement begins only after an owner-approved baseline-cleanup task.
2. **Baseline build scope.** The document's required Windows app gate cannot be run from this Linux host. Record a Windows runner result before cutover, release, or T4.7 completion. A Linux debug build is useful extra validation but does not replace `flutter build windows --debug`.
3. **Clean branch required.** Start implementation from a clean worktree or explicitly preserve and isolate the owner's existing uncommitted changes. Do not mix task branches with unrelated edits. _[UPDATE: outdated, safe to build upon. If unsure about current branch or its state, do not rely on this]_ The repository is currently dirty and is already on `v2/integration`; create task branches only after confirming the owner approves the existing changes as the integration baseline.
4. **Toolchain.** The checked project declares `environment: sdk >=3.0.0 <4.0.0`, but this handout is executable only with the verified baseline toolchain: Flutter 3.44.8 and Dart 3.12.2 or newer compatible releases. T0.2 must add/verify package SDK constraints instead of assuming every Dart 3.0 SDK can resolve the selected dependencies.
5. **Required inputs are missing.** No `test/fixtures/**`, `test/golden/**`, `assets/rules/**`, or `supabase/**` content exists yet. Owner-supplied statement fixtures and Supabase credentials are blockers. No synthetic or real transaction may be invented or committed.
6. **Existing database path.** V1 opens `budget_audit/db.sqlite` under `getApplicationSupportDirectory()`. T2.4 and T4.7 must use that exact path as read-only input. The v2 database must have a separate filename and T4.7 must first copy the v1 file to a backup beside the v2 data directory.
7. **New dependencies need resolution.** The root project does not currently contain `cryptography`, `cryptography_flutter`, `supabase_flutter`, `flutter_secure_storage`, or a BIP-39/QR package. T0.2/T6.x tasks must add only dependencies that belong in each package and update lockfiles through `flutter pub get`.
8. **Existing naming drift.** V1 currently uses the term "Account" in the database and UI, while v2 uses "Category". The migrator and v2 UI must maintain the explicit mapping in section 7.2; the user-facing v2 UI must never call a v2 Category an Account.

## 0. Rules of engagement (read first)

1. **One task at a time.** Do only the task you were given. Do not start the next one, and do not pre-build things later tasks will need.
2. **Allowed files are a hard fence.** Each task lists the paths it may create or edit. Everything else is read-only: v1 code, the router, themes, pubspec (unless the task says so) and generated files you did not generate.
3. **Do not rebuild, rename, move, reformat or tidy anything outside the task.** No refactors for taste, no folder moves, no style churn, no dependency upgrades, and no new abstractions the task does not name.
4. **Size cap: about 15 files changed and 600 net lines per task.** If you are heading past that, stop and propose a split.
5. **Rescope note, not rescope.** If a task cannot be finished inside its fence, stop and write a note: what blocks it, the smallest extra change that would unblock it, and what you could do without it. Then wait for the owner. Preferences and 'it would be cleaner if' are not blockers.
6. **Ambiguity:** choose the simplest option, log it in one line in `docs/DECISIONS.md`, and continue. Ask only about blockers.
7. **Never invent data.** Fixture statements, a v1 database copy and Supabase credentials come from the owner. If one is missing when a task needs it, stop and ask. Never commit real transactions.
8. **Secrets.** Never commit credentials. Read them from build-time defines (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `RULES_BUNDLE_URL`, `RULES_PUBLIC_KEY`). The service-role key never appears in the app.
9. **Report at the end of each task:** files changed, tests added, gate results, decisions logged, open questions. Keep it short.

### Gates

- **Core gate (every task):** `dart analyze` and the tests of every package you touched are green. `dart analyze` is run in each touched package.
- **App gate (tasks that touch `lib/`):** In a clean Windows environment, `flutter analyze` and `flutter build windows --debug` succeed, and the existing v1 tests still pass. Until the baseline debt is cleaned by an owner-approved task, report the baseline analyzer issue delta instead of falsely claiming 251 existing issues are green.
- **Cutover (T4.7) onward:** the app gate covers everything, plus a launch smoke test.

### Why v1 keeps working during the build

New engines live in packages that v1 does not import. New UI lives in `lib/v2/` and is not reachable until the `USE_V2` flag is on. The v2 database is a separate file from the v1 database. So v1 compiles and runs throughout, and **you never edit v1 files to make v2 work**. Only T4.1 touches `lib/main.dart`, and only to add the flag. Only T4.8 deletes v1.

### Branches and commits

- `main` stays v1 and takes fixes only. `v2/integration` is the long-lived v2 line.
- One branch per task, cut from `v2/integration`, named `v2/t1-2-reconciler`. Merge with `--no-ff` once the gates pass, then delete the branch. Tag the end of each milestone `v2.0.0-alpha.N`.
- Never commit directly to `main` or `v2/integration`. Never force-push shared branches.
- Conventional commits that end with the task id, for example `feat(core): add reconciler with full, partial and none levels (T1.2)`. Several small commits per task are fine.

## 1. Product framing (FIXED)

Budget Audit answers: **where did my money go, and how does it compare with my budget?** Requirements: (1) create a budget, (2) evaluate expenditure against it, (3) show analysis that supports decisions.

1. End-to-end encryption is non-negotiable. The server never sees plaintext data, passwords or the DEK.
2. One vault per user, never shared. Partner features (exchange of encrypted aggregate reports) are out of scope for 2.0.0.
3. Authentication (Supabase) and decryption (the DEK) are separate. Logging in does not unlock the vault.
4. Offline-first. Everything except sync and rule updates works with no network.
5. Expenditure only. Money in is not stored. Money moved into savings is an outflow in a saving category.
6. Categories belong to the user. A budget is an immutable selection of (category, amount) lines.
7. Spend versus budget is derived at read time. Never store running totals.
8. UUID primary keys, integer minor-unit money, soft deletes.
9. Statement parsing is rule data interpreted by one engine, not one class per bank.
10. Removed, not hidden: Google Sheets, participants, roles, templates and group budgeting.

## 2. Vocabulary (use these names in code and UI)

| Term | Meaning | V1 equivalent |
| --- | --- | --- |
| Vault | The user's encrypted data boundary, one per user | none |
| Category | A leaf the user tags spending with, e.g. Electricity, Venice trip | Account |
| Group | Optional user-defined label bundling categories, e.g. Household | Category |
| Budget | Immutable versioned list of category amounts for a period | Template |
| Budget line | One (category, amount) pair in a budget | Account.budgetAmount |
| Vendor | A normalised counterparty name | Vendor |
| Vendor default | The category a vendor usually maps to; a suggestion only | VendorMatchHistory, VendorPreference |
| Set aside | Outflow into an `is_saving` category, reported separately from Spent | none |
| Chunk | Unit of encrypted sync: one per month of transactions, plus one config chunk | none |

UI copy says Category, never Account.

## 3. Repo layout and dependency rule

- `packages/ba_core`: pure Dart. No Flutter, no Drift, no PDF library. Money helpers, parser engine, reconciler, rules, report builder, merge, chunker.
- `packages/ba_data`: Drift v2 schema, DAOs, migrator. Depends on `ba_core`.
- `packages/ba_crypto`: crypto wrappers and key hierarchy. Depends on nothing else of ours.
- `lib/v2/`: adapters (the PDF library lives only here), services, view models and views for v2.
- `lib/` (existing): v1. Untouched until T4.7 and T4.8.
- Dependencies point down only: `lib/v2` to `ba_data` to `ba_core`. `ba_core` never imports Flutter or Drift.
- State management, navigation and widget conventions stay as in v1 (Provider, ChangeNotifier, go\_router, MVVM).

Approved new dependencies (anything else needs the owner's yes): `drift`, `sqlite3`, `uuid`, `cryptography` (and `cryptography_flutter`), `supabase_flutter`, `flutter_secure_storage`, a BIP-39 package, a QR package, plus the existing Syncfusion PDF package.

## 4. Local schema (Drift, SQLite) - used by T2.1

Every table has `updated_at` (UTC epoch ms). Money is `amount_minor INTEGER`. IDs are UUID v4 text.

```sql
groups(id pk, name, sort, color, archived_at, updated_at)
categories(id pk, group_id null, name, is_saving, color, archived_at, updated_at)
vendors(id pk, name, updated_at)
vendor_defaults(vendor_id pk, category_id, use_count, last_used, updated_at)
transactions(id pk, date, vendor_id, category_id, amount_minor, note,
             source_ref null, is_manual, deleted_at, updated_at)   -- outflows only
budgets(id pk, name, period, effective_from, supersedes_id null, archived_at, updated_at)
budget_lines(budget_id, category_id, amount_minor, pk(budget_id, category_id))
sync_state(chunk_id pk, base_version, dirty, last_synced)
meta(key pk, value)   -- schema_version, device_id, currency (default KES), later vault_id
```

- Unique partial index on `transactions(source_ref)` where not null: import deduplication.
- Budgets and lines are never updated after creation. Editing creates a new budget with `supersedes_id` and a new `effective_from`.
- The active budget for a date is the non-archived budget with the greatest `effective_from` on or before it. One active budget at a time.
- A vendor default is a suggestion. A per-transaction override updates the default.
- Spend in a category the active budget does not include is reported as unbudgeted.
- `is_saving` categories count as Set aside, never as Spent.
- A transaction's chunk is `tx:YYYY-MM` from its date; everything else lives in the `config` chunk.
- Store v2 data in a separate file named `budget_audit_v2.sqlite` in the same application-support data directory. The v1 database remains `budget_audit/db.sqlite`.

## 5. UI changes (built in milestone E only)

Remove: participant management, local-password login, roles, template sharing, Google Sheets screens, group budgeting flows.

Navigation: **Home** (where the money went: Spent, Set aside, remaining, top categories, unbudgeted callout), **Import** (validate, preview, assign categories with vendor-default suggestions, confirm, reconciliation status), **Budget** (view active, create a new version, copy previous, starting shapes: blank, copy last, 50/30/20 at group level), **Categories** (create, rename, archive, group, saving flag, manual saving entry), **Analysis** (budget versus actual by category and group, monthly trend, top vendors, set aside versus spent), **Settings** (currency, export, later Security and Devices).

Onboarding: starter categories the user can edit, then the first budget. An account is an optional upgrade from Settings. Every screen has an empty state, and errors are plain language, never raw exceptions.

## 6. Task plan

Each row is one task, one branch, one merge. Allowed files are the fence from section 0. Milestones end with an owner review and an alpha tag.

### Milestone A - Safety net (no behaviour change)

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T0.1 | Record golden outputs of the existing M-PESA, Equity, CSV and OFX parsers from owner-supplied synthetic fixtures _[CSV and OFX are standardized formats, if the format matches what is in test/golden, no parsing is needed]_ | `test/golden/**`, `~~test/fixtures/**~~ _[UPDATE .pdf/**]_ `  | One golden JSON per fixture; a test re-runs the old parser and matches it; no `lib/` change |
| T0.2 | Create empty packages `ba_core`, `ba_data`, `ba_crypto` and path dependencies | `packages/**`, `pubspec.yaml`, `analysis_options.yaml`, `pubspec.lock` | Each package has its own pubspec with a compatible SDK constraint and placeholder test; root path dependencies resolve; `flutter pub get` and the app build succeed |

### Milestone B - Parser engine (core stays pure)

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T1.1 | `ParsedRow` contract, minor-unit money parsing, date parsing helpers | `packages/ba_core/lib/models/**`, `packages/ba_core/lib/money/**`, `packages/ba_core/test/**` | Tests for thousands and decimal formats, rounding, negatives |
| T1.2 | Reconciler with `full`, `partial`, `none` levels | `packages/ba_core/lib/reconcile/**`, tests | An altered balance fails; Cr/Dr balances handled; OFX-style ending-balance check passes |
| T1.3 | Rule model, JSON loader, validator | `packages/ba_core/lib/rules/**`, tests | Invalid rules rejected with a clear message; sample rules load |
| T1.4 | `header_table` interpreter over a list of positioned words (pure) | `packages/ba_core/lib/engine/**`, tests | Hand-built word lists cover wrapped details, an empty cell, reordered columns |
| T1.5 | Syncfusion adapter: PDF to positioned words | `lib/v2/adapters/**`, its test | Returns words with bounds for a fixture; the verified API is noted in `DECISIONS.md` |
| T1.6 | `mpesa.json` rule and parity with its golden | `assets/rules/mpesa.json`, parity test | Output equals the golden except differences listed in `DECISIONS.md` |
| T1.7 | `equity.json` rule and parity | `assets/rules/equity.json`, parity test | Same as T1.6 |
| T1.8 | CSV extractor and one CSV rule | `packages/ba_core/lib/extract/csv/**`, rule, tests | Parity with the CSV golden |
| T1.9 | Tolerant OFX extractor (tag scanner, not an XML parser) and rule | `packages/ba_core/lib/extract/ofx/**`, rule, tests | Handles SGML-style v1 files with unclosed tags and date suffixes such as `[3:EAT]`; `FITID` becomes `source_ref` |

### Milestone C - Data layer (no UI)

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T2.1 | Drift v2 schema | `packages/ba_data/lib/schema/**`, tests | In-memory tests for the unique `source_ref` index and foreign keys |
| T2.2 | DAOs: groups, categories, vendors, vendor defaults | `packages/ba_data/lib/dao/**`, tests | CRUD plus archive; default upsert increments `use_count` |
| T2.3 | DAOs: transactions (dedupe) and immutable budgets with lines | `packages/ba_data/lib/dao/**`, tests | Duplicate `source_ref` is ignored; budgets cannot be mutated through the API |
| T2.4 | V1 migrator reading the v1 file with raw read-only SQL | `packages/ba_data/lib/migrator/**`, `test/fixtures/v1/**`, `packages/ba_data/test/**` | Fixture migrates with matching counts and totals; idempotent; the input path `budget_audit/db.sqlite` is opened in read-only mode and is never modified |

### Milestone D - Domain logic (no UI)

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T3.1 | `BudgetResolver` and pure `ReportBuilder` | `packages/ba_core/lib/report/**`, tests | Tests: unbudgeted spend, set aside, budget version change mid-history, archived categories |
| T3.2 | `ImportService`: adapter, engine, reconcile, dedupe, vendor suggestions | `lib/v2/services/import_service.dart`, tests | Importing a fixture twice adds zero rows |
| T3.3 | Walking skeleton: a command that imports a fixture into a temp v2 database and prints a report | `tool/ba_dev.dart` | Runs end to end from the command line |

### Milestone E - UI and cutover

Build these only inside `lib/v2/features/**`, using the existing MVVM conventions.

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T4.1 | `USE_V2` flag, v2 router and empty shell | `lib/main.dart` (flag line only), `lib/v2/app/**` | Default build is unchanged; the flag build shows the v2 shell |
| T4.2 | Categories and groups screen, manual saving entry | `lib/v2/features/categories/**` | Create, rename, archive, set group and saving flag |
| T4.3 | Budget screen | `lib/v2/features/budget/**` | New version, copy previous, three starting shapes |
| T4.4 | Import screen | `lib/v2/features/import/**` | Validate, preview, assign, confirm; reconciliation level shown |
| T4.5 | Home and Analysis screens driven by `Report` | `lib/v2/features/home/**`, `analysis/**` | Matches the section 5 description |
| T4.6 | Onboarding | `lib/v2/features/onboarding/**` | New user reaches Home with categories and a budget |
| T4.7 | **Cutover.** Needs owner approval after the owner has validated the migrator on a copy of real v1 data. Copy `budget_audit/db.sqlite` as a backup before migration, migrate at first launch, flip the default | `lib/main.dart`, `lib/v2/app/**` | v1 users open v2 with their data; the timestamped backup exists beside the v2 data; migration is idempotent and never opens v1 for write |
| T4.8 | Delete v1 Dart code and the flag, in its own easily reverted merge | `lib/**` (deletions only) | Everything green; no import of removed v1 code |
| T4.9 | Remove obsolete v1 dependencies, assets and platform integrations | `pubspec.yaml`, `pubspec.lock`, `assets/**`, `android/**`, `ios/**`, `linux/**`, `macos/**`, `windows/**` | Remove Google Sheets/group/participant-only dependencies and assets only when no v2 code imports them; app builds on owner-approved platforms |

### Milestone F - Remote rule updates

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T5.1 | Signed bundle format and verification (verifier injected), version and `engine_min` checks | `packages/ba_core/lib/rules/bundle/**`, tests | Tampered and downgraded bundles are rejected |
| T5.2 | Layered `RulesSource`: bundled asset, cache directory, remote URL | `lib/v2/rules/**`, tests | Offline first run works from the asset |
| T5.3 | Fallback ladder in `ImportService`, opt-in failure-report queue, plain-language UI | `lib/v2/services/**`, `lib/v2/features/import/**` | A changed header fails on old rules and succeeds after a newer bundle loads |
| T5.4 | Bundle signing script and fixture check | `tool/rules/**` | Script signs a bundle and runs every rule on fixtures |

### Milestone G - Account and keys (needs Supabase credentials from the owner)

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T6.1 | Server migration and policy tests (the owner applies it) | `supabase/migrations/**`, `supabase/tests/**` | SQL from section 7.3; a second test user cannot read the first user's rows |
| T6.2 | Supabase config, `AuthGateway`, sign up, in and out | `lib/v2/remote/**`, `lib/v2/features/account/**` | Session persists across restarts |
| T6.3 | Crypto primitives with known-answer tests | `packages/ba_crypto/**` | AES-GCM, Argon2id, X25519, HKDF, Ed25519 verified against test vectors |
| T6.4 | Key hierarchy: DEK, password wrap, recovery wrap, 12-word phrase | `packages/ba_crypto/lib/hierarchy/**`, tests | Round trips; wrong password fails; wrapped blobs hold no plaintext |
| T6.5 | Setup, unlock, recovery and change-password flows | `lib/v2/features/security/**` | Forget password then recover with the phrase, data untouched |
| T6.6 | Adopt local data into the vault (store `vault_id`, no upload) | `lib/v2/features/account/**`, `lib/v2/services/**` | Local-only use still works when signed out |

### Milestone H - Encrypted sync

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T7.1 | Chunker and chunk encryption (pure) | `packages/ba_core/lib/sync/chunker/**`, tests | Round trip; tampered ciphertext fails clearly |
| T7.2 | Record-level `MergeEngine` | `packages/ba_core/lib/sync/merge/**`, tests | Two clients converge identically in either order |
| T7.3 | `ChunkTransport` interface and Supabase Storage implementation | `packages/ba_core/lib/sync/transport.dart`, `lib/v2/remote/**` | Upload, confirm and download work against a test project |
| T7.4 | `SyncService` (dirty tracking, push, pull, conflict loop) and status UI | `lib/v2/services/sync/**`, `lib/v2/features/sync/**` | Conflict loop terminates; status and last-synced shown |
| T7.5 | Restore on a clean install | `lib/v2/features/restore/**` | Delete the local database, sign in, unlock, totals match |

### Milestone I - Devices and release

| ID | Task | Allowed files | Done when |
| --- | --- | --- | --- |
| T8.1 | Device keypair and QR pairing, with copy-paste fallback for desktops | `lib/v2/features/devices/**`, `packages/ba_crypto/lib/device/**` | Second device gets the DEK without the server seeing it |
| T8.2 | Device list, revoke, DEK rotation | same | Revoked device cannot fetch new data; rotation completes |
| T8.3 | Account deletion, data export and import | `lib/v2/features/settings/**` | Deletion removes server rows and local keys |
| T8.4 | Hardening checklist and recovery drill | `docs/**` | Checklist signed off by the owner |

## 7. Specs the tasks refer to

### 7.1 Parser contract and rule format (T1.x)

- Output: `ParsedRow(ref, date, vendorRaw, amountMinor, direction, balanceMinor?)`. The engine parses inflows too, to reconcile, then drops them before returning.
- The pipeline has three stages: an **extractor** turns a file into raw records (`pdf_words`, `csv`, `ofx`), the **interpreter** applies the rule, and the **reconciler** verifies.
- For PDFs, find the header row by label, derive each column's x-range, assign words to columns, and start a new row when the designated column matches a pattern. Other lines are continuations appended to the previous row's details. Regex only validates a single cell or cleans a vendor string.
- A rule is JSON with `institution`, `rule_version`, `engine_min`, `extractor`, `detect`, `layout`, `direction`, `fields`, `keep_rows`, `skip_rows_containing` and an ordered `vendor` list where the first matching step wins. Direction modes: `columns`, `signed`, `drcr_column`, `balance_delta` (fallback only). No loops or nested conditionals in the format. If a bank seems to need them, file a rescope note.
- Reconciliation levels: `full` (every row against the running balance), `partial` (opening plus rows equals the ending balance, as in OFX), `none` (the user confirms from the preview).
- Capture the receipt number or `FITID` as `source_ref`. Money is never a double.

### 7.2 V1 migrator mapping (T2.4)

Read the v1 file read-only with raw SQL. Write only to the v2 file.

- v1 Categories become Groups. v1 Accounts become Categories, de-duplicated by case-insensitive (group, name).
- Each Template becomes a Budget (`effective_from` is its creation date), chained with `supersedes_id`. Each account's `budgetAmount` becomes a budget line.
- Transactions: amount times 100, rounded; account mapped to category; `is_manual` false; `source_ref` null.
- VendorMatchHistories collapse into `vendor_defaults`, taking the category with the highest `use_count` per vendor. VendorPreferences has no category mapping in v1 and is dropped.
- Dropped: Participants, TemplateParticipants, SyncLog, ChartSnapshots, ParticipantIncomes (export the last to a JSON file beside the backup first). Collapse other participants' transactions into the one local owner and record the count.

### 7.3 Server schema (T6.1)

```sql
create table public.vaults (
  vault_id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references auth.users(id) on delete cascade,
  created_at timestamptz not null default now());
create table public.wrapped_keys (
  vault_id uuid not null references public.vaults(vault_id) on delete cascade,
  wrap_method text not null,   -- 'password', 'recovery_phrase', 'device:<uuid>'
  wrapped_dek text not null,
  kdf_params jsonb,
  updated_at timestamptz not null default now(),
  primary key (vault_id, wrap_method));
create table public.devices (
  device_id uuid primary key,
  vault_id uuid not null references public.vaults(vault_id) on delete cascade,
  name text, public_key text not null,
  created_at timestamptz not null default now(), revoked_at timestamptz);
create table public.sync_metadata (
  vault_id uuid not null references public.vaults(vault_id) on delete cascade,
  chunk_id text not null, version bigint not null, object_key text not null,
  last_modified_by_device text,
  last_updated timestamptz not null default now(),
  primary key (vault_id, chunk_id));

create or replace function public.confirm_chunk(
  p_vault_id uuid, p_chunk_id text, p_base_version bigint,
  p_object_key text, p_device text)
returns bigint language plpgsql security invoker set search_path = ''
as $$
declare new_v bigint;
begin
  if p_base_version = 0 then
    insert into public.sync_metadata (vault_id, chunk_id, version, object_key, last_modified_by_device)
    values (p_vault_id, p_chunk_id, 1, p_object_key, p_device)
    on conflict do nothing returning version into new_v;
  else
    update public.sync_metadata
       set version = version + 1, object_key = p_object_key,
           last_modified_by_device = p_device, last_updated = now()
     where vault_id = p_vault_id and chunk_id = p_chunk_id and version = p_base_version
    returning version into new_v;
  end if;
  if new_v is null then raise exception 'version_conflict'; end if;
  return new_v;
end $$;
```

- Enable RLS on all four tables. One policy pattern each, for both `using` and `with check`: the row's vault belongs to a vault whose `owner_id = (select auth.uid())`. The signup trigger inserts `owner_id` only, with `set search_path = ''` and schema-qualified names. Keep the diagnostic `test` table out of production.
- Create a private bucket `vault-chunks`. A policy on `storage.objects` allows authenticated users only objects whose first folder is a vault they own (`(storage.foldername(name))[1]` matched against `vaults.vault_id::text` and `owner_id`).

### 7.4 Keys and crypto rules (T6.x, T8.x)

- Use audited packages. Never hand-roll primitives.
- A random 256-bit DEK encrypts data. It is wrapped by a password-derived key and by a recovery-phrase-derived key (Argon2id, parameters stored in `kdf_params`, tuned on the slowest target device and recorded in `DECISIONS.md`).
- AES-256-GCM with a fresh random 96-bit nonce for every encryption. Chunk id and schema version are associated data.
- Show the 12-word recovery phrase once at setup, require the user to re-enter selected words, and never store it.
- Changing the password re-wraps the same DEK. Data is never re-encrypted for that.
- Device wrapping: ephemeral X25519 plus HKDF plus AES-GCM. Be honest in the UI that revoking a device cannot erase a DEK it already held; real revocation is DEK rotation.
- Never log keys, phrases, tokens or transaction text.

### 7.5 Sync rules (T7.x)

```dart
abstract class ChunkTransport {
  Future<Manifest> fetchManifest(String vaultId);
  Future<Uint8List> download(String vaultId, String chunkId);
  /// Uploads to a random object key, then commits atomically.
  /// Throws VersionConflict if baseVersion is stale. Returns the new version.
  Future<int> uploadAndCommit(String vaultId, String chunkId, int baseVersion,
      Uint8List ciphertext, String deviceId);
}
```

- Upload to `{vault_id}/{chunk_id}/{random-uuid}`, then call `confirm_chunk`. On `version_conflict`, delete the orphan, pull, merge, retry. Delete the superseded object after a successful confirm.
- Merge rule, one for every table: union by `id`; the later `updated_at` wins; `deleted_at` counts as an edit. Ordinary conflicts never prompt the user.
- Chunks: `tx:YYYY-MM` per month plus one `config` chunk. Editing a record marks only its chunk dirty.

## 8. Infrastructure decisions

1. **No custom server.** The app talks to Supabase directly: Auth, RLS, Storage and the `confirm_chunk` function. Moving chunk storage to R2 later means writing a second `ChunkTransport`, with no change to chunking, encryption or merge.
2. **Rules hosting:** any static host. Signed bundles make the host untrusted.
3. **Failure-report endpoint:** undecided. Keep the local queue until the owner chooses.
4. **Free-plan caution:** Supabase free projects pause after a week of inactivity. Use a paid plan once real users depend on sync.

## 9. Out of scope for 2.0.0

Partner or household reports, shared vaults, income tracking, savings goals, LLM categorisation, OCR of scanned statements, multi-currency, and tap-to-map-columns. The `Report` object, `is_saving` categories, `vendor_defaults` and the rule format are the seams for these, so none should need a schema change. Do not start any of them.
