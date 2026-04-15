# Fixing Canvas PDF Accessibility Warnings (Tagged PDFs)

## The problem

Canvas's accessibility checker flags PDFs that lack "structure tags" --- metadata that labels headings, paragraphs, lists, and other elements for screen readers. If you generate PDFs using **PDFLaTeX**, **XeLaTeX**, or **Pandoc** (with its default LaTeX backend), your PDFs almost certainly lack these tags. LaTeX does not add them by default, and the packages that try (`tagpdf`, `accessibility`) are unreliable.

The fix is simple: use **Typst** as the PDF engine instead. Typst generates tagged, accessible PDFs by default, and Pandoc 3.x can use it as a drop-in replacement backend.

## What you need

- **Pandoc 3.x** (check with `pandoc --version`)
- **Typst** (check with `typst --version`)

### Installing on macOS (Homebrew)

```bash
brew install pandoc typst
```

### Installing on other systems

- Pandoc: https://pandoc.org/installing.html
- Typst: https://github.com/typst/typst#installation

## Quick fix: one file at a time

If you have a **Markdown** file you've been converting to PDF:

```bash
# Before (untagged)
pandoc syllabus.md -o syllabus.pdf

# After (tagged)
pandoc --pdf-engine=typst syllabus.md -o syllabus.pdf
```

That's it. The `--pdf-engine=typst` flag is the only change.

This also works for **LaTeX source files**:

```bash
pandoc --pdf-engine=typst syllabus.tex -o syllabus.pdf
```

Pandoc will parse your LaTeX, convert it internally, and produce a tagged PDF through Typst. You may see a warning about "unusual conversion" --- this is safe to ignore. Note that very complex LaTeX (custom packages, TikZ diagrams, low-level TeX commands) may not convert cleanly; see [Limitations](#limitations) below.

## Batch processing: convert all your PDFs at once

If you have a folder of Markdown or LaTeX files you'd like to reconvert, here are some one-liner scripts.

### All Markdown files in a directory tree

```bash
find /path/to/course -name '*.md' -exec sh -c '
  for f; do
    out="${f%.md}.pdf"
    echo "Converting: $f"
    pandoc --pdf-engine=typst "$f" -o "$out"
  done
' _ {} +
```

### All LaTeX files in a directory tree

```bash
find /path/to/course -name '*.tex' -exec sh -c '
  for f; do
    out="${f%.tex}.pdf"
    echo "Converting: $f"
    pandoc --pdf-engine=typst "$f" -o "$out"
  done
' _ {} +
```

### Dry run first

If you want to preview what would be converted before actually doing it, replace the `pandoc` line with `echo`:

```bash
find /path/to/course -name '*.md' -exec sh -c '
  for f; do
    echo "Would convert: $f -> ${f%.md}.pdf"
  done
' _ {} +
```

## Making Typst the default Pandoc PDF engine

To avoid typing `--pdf-engine=typst` every time, create (or edit) a Pandoc defaults file.

### Step 1: Create the defaults file

```bash
mkdir -p ~/.pandoc/defaults
```

Create `~/.pandoc/defaults/pdf.yaml` with:

```yaml
pdf-engine: typst
```

### Step 2: Use it

```bash
pandoc -d pdf syllabus.md -o syllabus.pdf
```

The `-d pdf` flag tells Pandoc to load `~/.pandoc/defaults/pdf.yaml`. You can add other defaults to this file too (fonts, margins, etc.).

### Optional: keep your old LaTeX config available

If you occasionally need the LaTeX backend (e.g., for a document that requires specific LaTeX packages), create a second defaults file at `~/.pandoc/defaults/pdf-latex.yaml`:

```yaml
pdf-engine: xelatex
variables:
  mainfont: "Your Preferred Font"
```

Then use `pandoc -d pdf-latex ...` when you need it.

## Verifying your PDFs are tagged

You can check whether a PDF is tagged using `pdfinfo` (part of the `poppler` package):

```bash
pdfinfo syllabus.pdf | grep Tagged
```

- `Tagged: yes` --- Canvas should accept this.
- `Tagged: no` --- Canvas will flag it.

Install `poppler` if you don't have it:

```bash
brew install poppler
```

## Limitations

This approach works well for:

- Markdown files (syllabi, handouts, assignment descriptions)
- Simple to moderately complex LaTeX files (most course documents)

It may not work well for:

- **LaTeX files with heavy package dependencies** (e.g., `tikz` for diagrams, `minted` for code highlighting, custom class files). Pandoc's LaTeX parser handles standard LaTeX but may choke on specialized packages.
- **Beamer presentations.** Pandoc can convert Beamer to PDF via Typst, but complex slide layouts may not survive the conversion.
- **Documents with very specific formatting requirements** (e.g., grant proposals with strict templates). In these cases, stick with your LaTeX workflow.

For these cases, you have a few options:

1. **Use LaTeX's `tagpdf` package** --- adds tagging to LaTeX output, but requires LuaLaTeX and can be finicky. See https://ctan.org/pkg/tagpdf.
2. **Accept the Canvas warning** --- an imperfectly tagged PDF that students can access is better than no PDF at all.

## What about journal articles and other PDFs you didn't create?

Canvas will also flag published journal articles and other third-party PDFs that lack tags. You can't fix these --- tagging is the publisher's responsibility, and removing the PDFs would make your course *less* accessible, not more. If your accessibility office raises this, the standard position is that providing the materials is itself an accommodation, and publishers are responsible for the accessibility of their own publications.

## Further reading

- Typst documentation: https://typst.app/docs
- Pandoc manual on PDF engines: https://pandoc.org/MANUAL.html#option--pdf-engine
- PDF accessibility overview: https://www.w3.org/WAI/WCAG21/Techniques/pdf/
