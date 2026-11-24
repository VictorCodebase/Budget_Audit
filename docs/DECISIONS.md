# Implementation Decisions

- 2026-11-24: Syncfusion PDF positioning is provided by
  `PdfTextExtractor.extractTextLines`, with each `TextWord.bounds` carrying
  the word rectangle and page range used to assign the page index (T1.5).
- 2026-11-25: The redacted M-PESA PDF's V1 golden is successful but empty. T1.6
  intentionally diverges by returning its detail rows, including Paid In as
  credits and Withdrawn as debits; the supplied V1 output cannot be used as a
  populated transaction oracle for this fixture.
- 2026-11-25: M-PESA receipt groups may omit repeated date/reference cells on
  later completed rows. The rule starts rows at `Transaction Status` and
  inherits only the date and receipt reference. Footer text is ignored rather
  than appended to the last transaction's details.
- 2026-11-25: Equity PDF parity is verified against the legacy golden's seven
  transaction dates and signed minor-unit amounts. The PDF positions some
  counterparty/detail words in the Money Out/In columns, so the rule marks
  those columns numeric and the table interpreter keeps amount tokens while
  moving adjacent text into particulars when an amount is present. Non-amount
  counterparty text in an otherwise empty amount column is ignored. Vendor
  names are intentionally normalized by the V2 rule; parity does not require
  the legacy vendor labels or exact description strings.
- 2026-11-25: The legacy Equity CSV golden contains no transactions because
  the V1 CSV parser reports "No valid transactions found in CSV file." T1.8
  intentionally parses the seven supplied rows with the generic CSV rule and
  fully reconciles them from the fixture's 1,324.88 Cr opening balance to its
  1,970.91 Cr ending balance.
- 2026-11-25: OFX parity covers all seven Equity and 47 M-PESA transactions by
  date and amount magnitude. The V1 OFX parser turns negative `DEBIT`
  `TRNAMT` values positive, so V2 intentionally preserves the signed source
  amounts as debit/credit directions; V2 also retains each `FITID` as
  `source_ref`. The generic rule maps its ending balance to `BALAMT`, not the
  enclosing `LEDGERBAL` tag.
