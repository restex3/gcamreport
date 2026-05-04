library(gcamreport)

cat("Adding all V8 query objects...\n")

queries_general_vGCAMChina8.0 <- queries_general_vGCAMChina7.1
queries_nonCO2_vGCAMChina8.0 <- queries_nonCO2_vGCAMChina7.1

cat("  - queries_general:", length(queries_general_vGCAMChina8.0), "\n")
cat("  - queries_nonCO2:", length(queries_nonCO2_vGCAMChina8.0), "\n")

usethis::use_data(
  queries_general_vGCAMChina8.0,
  queries_nonCO2_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("\nDone!\n")
