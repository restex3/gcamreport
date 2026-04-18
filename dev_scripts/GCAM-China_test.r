devtools::load_all(".", reset = TRUE)
source("inst/extdata/saveDataFiles_GCAMChina7.1.R")
devtools::load_all(".")
library(gcamreport)
dbpath <- "E:/GCAM/GCAM-China_v7.1/output/"
dbname <- "steel_ref"
prjname <- "test.dat"
scen <- ("ref") #c("scen1", "scen2", "scen3")
GCAMv <- "vGCAMChina7.1"
generate_report(db_path = dbpath, db_name = dbname, prj_name = prjname,
                GCAM_version = GCAMv,
                scenarios = scen,
                final_year = 2060)
#generate_report(prj_name = "E:/GCAM/GCAM-China_v7.1/output/steel_ref_test.dat", scenarios = scen, final_year = 2060,
 #               GCAM_version = GCAMv, launch_ui = FALSE)
