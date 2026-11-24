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
