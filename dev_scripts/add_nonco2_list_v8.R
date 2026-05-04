library(gcamreport)

cat("Adding nonco2_emissions_list_vGCAMChina8.0...\n")
nonco2_emissions_list_vGCAMChina8.0 <- nonco2_emissions_list_vGCAMChina7.1
cat("  - Items:", length(nonco2_emissions_list_vGCAMChina8.0), "\n")

usethis::use_data(
  nonco2_emissions_list_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("\nDone! Adding to R/data.R...\n")
