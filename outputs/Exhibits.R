library(tinytex)

setwd("~/Projects/outsourcing-penalty/outputs/tables")

tables <- list.files(pattern = "^table.*\\.tex$") |> sort()
landscape_tables <- c("table1_janitors_workforce.tex", "table2_guards_workforce.tex")

preamble <- function(orient = "portrait") c(
  "\\documentclass[10pt]{article}",
  "\\usepackage[T1]{fontenc}",
  sprintf("\\usepackage[letterpaper, %s, margin=1in]{geometry}", orient),
  "\\usepackage{newtxtext}",
  "\\usepackage{booktabs, caption, longtable, array, multirow, colortbl, pdflscape}",
  "\\setlength{\\tabcolsep}{4pt}",
  "\\captionsetup{justification=centering}",
  "\\begin{document}"
)

# Tightened copy: natural width instead of stretched to the page
tighten <- function(f) {
  out <- paste0("tight_", f)
  readLines(f) |>
    gsub(pattern = "\\begin{tabular*}{\\linewidth}{@{\\extracolsep{\\fill}}",
         replacement = "\\centering\\begin{tabular}{", fixed = TRUE) |>
    gsub(pattern = "\\end{tabular*}",
         replacement = "\\end{tabular}\\par\\raggedright", fixed = TRUE) |>
    writeLines(out)
  out
}

# 1. Combined PDF: portrait pages, landscape where needed
body <- unlist(lapply(tables, \(f) {
  t <- tighten(f)
  if (f %in% landscape_tables) {
    c("\\begin{landscape}", sprintf("\\input{%s}", t), "\\end{landscape}", "\\clearpage")
  } else {
    c(sprintf("\\input{%s}", t), "\\clearpage")
  }
}))
writeLines(c(preamble(), body, "\\end{document}"), "all_tables.tex")
pdflatex("all_tables.tex")

# 2. Individual PDFs
dir.create("pdf", showWarnings = FALSE)
for (f in tables) {
  stem <- tools::file_path_sans_ext(f)
  orient <- if (f %in% landscape_tables) "landscape" else "portrait"
  wrapper <- paste0("render_", stem, ".tex")
  writeLines(c(preamble(orient), sprintf("\\input{%s}", tighten(f)), "\\end{document}"), wrapper)
  pdflatex(wrapper)
  file.rename(paste0("render_", stem, ".pdf"), file.path("pdf", paste0(stem, ".pdf")))
  file.remove(wrapper)
}

# 3. PNGs for Word: one per table page, trimmed to the table
# install.packages(c("pdftools", "magick"))  # once
library(pdftools)
library(magick)

dir.create("png", showWarnings = FALSE)
for (pdf in list.files("pdf", pattern = "\\.pdf$", full.names = TRUE)) {
  stem <- tools::file_path_sans_ext(basename(pdf))
  n_pages <- pdf_info(pdf)$pages
  pngs <- if (n_pages == 1) {
    file.path("png", paste0(stem, ".png"))
  } else {
    file.path("png", sprintf("%s_p%d.png", stem, seq_len(n_pages)))
  }
  pdf_convert(pdf, format = "png", dpi = 300, filenames = pngs, verbose = FALSE)
  for (p in pngs) {
    image_read(p) |>
      image_trim() |>
      image_border("white", "30x30") |>
      image_write(p, density = 300)
  }
}
