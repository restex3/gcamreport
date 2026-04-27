find_repo_dir <- function() {
  candidates <- c(".", "..", "../..", "E:/GCAM/GCAM_tools/gcamreport")

  for (candidate in candidates) {
    candidate_path <- tryCatch(
      normalizePath(candidate, winslash = "/", mustWork = TRUE),
      error = function(...) NULL
    )

    if (!is.null(candidate_path) &&
        file.exists(file.path(candidate_path, "DESCRIPTION"))) {
      return(candidate_path)
    }
  }

  stop(
    "Could not locate the gcamreport repository root. Run this script from the repo root or from dev_scripts/."
  )
}

repo_dir <- find_repo_dir()

devtools::load_all(repo_dir, reset = TRUE)
source(file.path(repo_dir, "inst", "extdata", "saveDataFiles_GCAMChina7.1.R"))
devtools::load_all(repo_dir)
library(gcamreport)
dbpath <- "E:/GCAM/GCAM-China_v7.1/output/"
dbname <- "steel_ref"
prjname <- file.path(repo_dir, "dev_scripts", "test.dat")
scen <- ("ref") #c("scen1", "scen2", "scen3")
GCAMv <- "vGCAMChina7.1"
generate_report(db_path = dbpath, db_name = dbname, prj_name = prjname,
                GCAM_version = GCAMv,
                scenarios = scen,
                final_year = 2060)
#generate_report(prj_name = "E:/GCAM/GCAM-China_v7.1/output/steel_ref_test.dat", scenarios = scen, final_year = 2060,
 #               GCAM_version = GCAMv, launch_ui = FALSE)
