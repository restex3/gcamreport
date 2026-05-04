library(gcamreport)
library(readr)

cat("Fixing V8 template...\n")

# Use GCAM 8.2 template for V8
template_vGCAMChina8.0 <- read_csv(
  "inst/extdata/template/GCAM8.2/common-definitions-template.csv",
  show_col_types = FALSE
)

cat("  - Rows:", nrow(template_vGCAMChina8.0), "\n")
cat("  - Cols:", ncol(template_vGCAMChina8.0), "\n")

usethis::use_data(
  template_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("\nDone!\n")
