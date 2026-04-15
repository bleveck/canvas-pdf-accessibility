# Canvas PDF Accessibility: Fixing "Untagged PDF" Warnings

Canvas's accessibility checker flags PDFs that lack structure tags --- metadata that labels headings, paragraphs, lists, and tables for screen readers. This is a common problem for faculty because most academic tools (LaTeX, Pandoc, Keynote) produce untagged PDFs by default.

This repo contains two guides and helper scripts for fixing these warnings.

## Guides

### 1. [Fixing PDFs You Generate Yourself](fixing_canvas_pdf_accessibility.md)

If you generate PDFs from **Markdown** or **LaTeX** using Pandoc, the fix is a one-line change: use [Typst](https://typst.app/) as the PDF engine instead of LaTeX. Typst produces tagged PDFs by default.

```bash
# Before (untagged)
pandoc syllabus.md -o syllabus.pdf

# After (tagged)
pandoc --pdf-engine=typst syllabus.md -o syllabus.pdf
```

Covers: single-file conversion, batch processing, making Typst the default engine, and verifying results.

**Requirements:** [Pandoc](https://pandoc.org/) 3.x, [Typst](https://github.com/typst/typst)

### 2. [Batch-Tagging Existing PDFs with Adobe Acrobat Pro](acrobat-batch-tagging/tagging_pdfs_with_acrobat.md)

For PDFs you didn't create (journal articles, book chapters, publisher PDFs), use Adobe Acrobat Pro's Action Wizard to batch-tag them. This guide includes:

- Helper scripts to identify untagged PDFs and stage them for processing
- Step-by-step Action Wizard setup with screenshots
- Troubleshooting for scanned PDFs (need OCR first) and permission-locked PDFs

**Requirements:** Adobe Acrobat Pro (available through most university site licenses), [poppler](https://poppler.freedesktop.org/) (`brew install poppler`), [qpdf](https://qpdf.sourceforge.io/) (`brew install qpdf`)

## Quick start

```bash
# Install dependencies (macOS)
brew install pandoc typst poppler qpdf

# Check if a PDF is tagged
pdfinfo document.pdf | grep Tagged

# Regenerate your own PDFs with tags
pandoc --pdf-engine=typst document.md -o document.pdf

# Find all untagged PDFs in a folder
./acrobat-batch-tagging/gather_untagged.sh /path/to/course/files
```

## Why is this a problem?

LaTeX (pdflatex, xelatex, lualatex) does not produce tagged PDFs by default. The packages that attempt to add tagging (`tagpdf`, `accessibility`) are unreliable. Since LaTeX is the dominant tool for producing academic documents, the vast majority of PDFs in higher education --- syllabi, homework assignments, lecture notes, and published research --- lack structure tags.

For journal articles and book chapters, the responsibility for tagging lies with the publisher, not the instructor. Providing untagged articles to students is more accessible than not providing them at all. However, Acrobat Pro's auto-tagger can add reasonable tags to most published PDFs in a few seconds per file.

## License

These guides and scripts are released into the public domain ([CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)). Use them however you like.
