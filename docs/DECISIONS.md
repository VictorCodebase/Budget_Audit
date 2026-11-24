# Implementation Decisions

- 2026-11-24: Syncfusion PDF positioning is provided by
  `PdfTextExtractor.extractTextLines`, with each `TextWord.bounds` carrying
  the word rectangle and page range used to assign the page index (T1.5).
