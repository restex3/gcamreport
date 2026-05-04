library(gcamreport)

cat("Adding queries_general_vGCAMChina8.0...\n")
queries_general_vGCAMChina8.0 <- queries_general_vGCAMChina7.1
cat("  - Queries:", length(queries_general_vGCAMChina8.0), "\n")

usethis::use_data(
  queries_general_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("\nDone! Now run devtools::document()\n")
