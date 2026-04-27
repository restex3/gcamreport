suppressPackageStartupMessages({
  library(devtools)
})

repo_root <- normalizePath("E:/GCAM/GCAM_tools/gcamreport", winslash = "/")
output_stub <- file.path(repo_root, "output", "tangrong_gains_latest")
db_path <- normalizePath("E:/GCAM/GCAM-China_v7.1/output", winslash = "/")
db_name <- "tangrong"
project_name <- "tangrong_gains_latest.dat"
project_path <- file.path(db_path, paste(db_name, project_name, sep = "_"))
mapping_file <- normalizePath("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv", winslash = "/")
province_mapping_file <- normalizePath("E:/GCAM/GCAM_tools/gcam2gains/mapping_province_names.csv", winslash = "/")

if (!dir.exists(file.path(db_path, db_name))) {
  stop(sprintf("Tangrong database directory not found: %s", file.path(db_path, db_name)))
}

if (!file.exists(mapping_file)) {
  stop(sprintf("GAINS mapping file not found: %s", mapping_file))
}

if (!file.exists(province_mapping_file)) {
  stop(sprintf("Province mapping file not found: %s", province_mapping_file))
}

dir.create(file.path(repo_root, "output"), recursive = TRUE, showWarnings = FALSE)

devtools::load_all(repo_root, reset = TRUE)
desired_regions <- c(
  "China",
  sort(unique(read.csv(province_mapping_file, stringsAsFactors = FALSE)$gcam))
)
mapping_data <- read.csv(mapping_file, stringsAsFactors = FALSE)
zero_fill_vars <- c(
  "Final Energy|Residential and Commercial|Solids|Biomass",
  "Final Energy|Residential and Commercial|Solids|Coal"
)

if (file.exists(project_path)) {
  gcamreport::generate_report(
    prj_name = project_path,
    desired_regions = desired_regions,
    GCAM_version = "vGCAMChina7.1",
    final_year = 2100,
    save_output = "CSV",
    output_file = output_stub,
    launch_ui = FALSE
  )
} else {
  gcamreport::generate_report(
    db_path = db_path,
    db_name = db_name,
    prj_name = project_name,
    desired_regions = desired_regions,
    GCAM_version = "vGCAMChina7.1",
    final_year = 2100,
    save_output = "CSV",
    output_file = output_stub,
    launch_ui = FALSE
  )
}

csv_path <- paste0(output_stub, ".csv")
report_csv <- read.csv(csv_path, stringsAsFactors = FALSE)
year_cols <- names(report_csv)[grepl("^\\d{4}$", names(report_csv))]
model_name <- unique(report_csv$Model)[1]
scenario_names <- sort(unique(report_csv$Scenario))

for (missing_var in zero_fill_vars) {
  if (!missing_var %in% report_csv$Variable) {
    unit_value <- unique(mapping_data$SOURCE_UNIT[mapping_data$SOURCE_VARIABLE == missing_var])[1]
    if (is.na(unit_value) || unit_value == "") {
      unit_value <- "EJ/yr"
    }

    zero_rows <- expand.grid(
      Model = model_name,
      Scenario = scenario_names,
      Region = "China",
      Variable = missing_var,
      Unit = unit_value,
      stringsAsFactors = FALSE
    )
    for (year_col in year_cols) {
      zero_rows[[year_col]] <- 0
    }
    report_csv <- dplyr::bind_rows(report_csv, zero_rows)
  }
}

write.csv(report_csv, csv_path, row.names = FALSE)

cat(sprintf("Tangrong upstream generated: %s.csv\n", output_stub))
