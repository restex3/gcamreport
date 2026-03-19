options(warn = 1)

repo_dir <- "E:/GCAM/GCAM_tools/gcamreport"
db_path <- "E:/GCAM/GCAM-China_v7.1/output"
db_name <- "China60Ref"
scenario_name <- "China60ref"
work_dir <- "E:/GCAM/GCAM_tools/tmp_china60ref_compare"
project_name <- "gcamreport_fullcheck.dat"
project_file <- file.path(db_path, paste(db_name, project_name, sep = "_"))
output_stub <- file.path(work_dir, "gcamreport_fullcheck")

regions <- c(
  "China","AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HL",
  "HN","JL","JS","JX","LN","NM","NX","QH","SC","SD","SH","SN","SX","TJ",
  "XJ","XZ","YN","ZJ"
)

dir.create(work_dir, showWarnings = FALSE, recursive = TRUE)

cat(format(Sys.time(), "%F %T"), "fullcheck: loading package\n")
suppressWarnings(devtools::load_all(repo_dir, quiet = TRUE))

cat(format(Sys.time(), "%F %T"), "fullcheck: generating report\n")
gcamreport::generate_report(
  prj_name = project_file,
  scenarios = scenario_name,
  final_year = 2060,
  desired_variables = "All",
  desired_regions = regions,
  save_output = "CSV",
  output_file = output_stub,
  launch_ui = FALSE,
  GCAM_version = "vGCAMChina7.1"
)

if (exists("vetting_summary", envir = .GlobalEnv)) {
  saveRDS(vetting_summary, file.path(work_dir, "fullcheck_vetting_summary.rds"))
}

cat(format(Sys.time(), "%F %T"), "fullcheck: completed\n")
