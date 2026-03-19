options(warn = 1)

repo_dir <- "E:/GCAM/GCAM_tools/gcamreport"
suppressWarnings(devtools::load_all(repo_dir, quiet = TRUE))

work_dir <- "E:/GCAM/GCAM_tools/tmp_china60ref_compare"
official_file <- file.path(work_dir, "official_GCAM_China_China60ref.csv")
gcamreport_file <- file.path(work_dir, "gcamreport_fullcheck.csv")
summary_file <- file.path(work_dir, "fullcheck_summary.txt")
overlap_file <- file.path(work_dir, "fullcheck_compare_overlap.csv")
official_only_file <- file.path(work_dir, "fullcheck_official_only.csv")
gcamreport_only_file <- file.path(work_dir, "fullcheck_gcamreport_only.csv")

library(dplyr)
library(readr)
library(tidyr)

years <- c("2020", "2025", "2030", "2040", "2050", "2060")

official <- read_csv(official_file, show_col_types = FALSE) %>%
  transmute(
    Scenario = scenario,
    Region = region,
    Variable = variable,
    Unit = unit,
    dplyr::across(dplyr::all_of(years))
  ) %>%
  dplyr::filter(Scenario == "China60ref", Region == "China") %>%
  dplyr::distinct(Variable, Unit, .keep_all = TRUE)

gcamreport <- read_csv(gcamreport_file, show_col_types = FALSE) %>%
  dplyr::select(Scenario, Region, Variable, Unit, dplyr::all_of(years)) %>%
  dplyr::filter(Scenario == "China60ref", Region == "China") %>%
  dplyr::distinct(Variable, Unit, .keep_all = TRUE)

overlap <- dplyr::inner_join(
  official %>% dplyr::select(Variable, Unit),
  gcamreport %>% dplyr::select(Variable, Unit),
  by = c("Variable", "Unit")
)

official_only <- dplyr::anti_join(
  official %>% dplyr::select(Variable, Unit),
  gcamreport %>% dplyr::select(Variable, Unit),
  by = c("Variable", "Unit")
)

gcamreport_only <- dplyr::anti_join(
  gcamreport %>% dplyr::select(Variable, Unit),
  official %>% dplyr::select(Variable, Unit),
  by = c("Variable", "Unit")
)

comparison <- dplyr::full_join(
  official %>% dplyr::semi_join(overlap, by = c("Variable", "Unit")),
  gcamreport %>% dplyr::semi_join(overlap, by = c("Variable", "Unit")),
  by = c("Variable", "Unit"),
  suffix = c(".official", ".gcamreport")
)

for (y in years) {
  comparison[[paste0("diff_", y)]] <-
    comparison[[paste0(y, ".gcamreport")]] - comparison[[paste0(y, ".official")]]
}

comparison$max_abs_diff <- apply(
  as.matrix(comparison[paste0("diff_", years)]),
  1,
  function(x) max(abs(x), na.rm = TRUE)
)

comparison <- comparison %>% dplyr::arrange(desc(max_abs_diff), Variable)

write.csv(comparison, overlap_file, row.names = FALSE)
write.csv(official_only, official_only_file, row.names = FALSE)
write.csv(gcamreport_only, gcamreport_only_file, row.names = FALSE)

summary_lines <- c(
  sprintf("official_china_vars=%d", nrow(official)),
  sprintf("gcamreport_china_vars=%d", nrow(gcamreport)),
  sprintf("overlap_vars=%d", nrow(overlap)),
  sprintf("exact_equal_overlap=%d", sum(comparison$max_abs_diff < 1e-9, na.rm = TRUE)),
  sprintf("non_equal_overlap=%d", sum(comparison$max_abs_diff >= 1e-9, na.rm = TRUE)),
  sprintf("official_only=%d", nrow(official_only)),
  sprintf("gcamreport_only=%d", nrow(gcamreport_only)),
  "",
  "top_remaining_diffs:"
)

summary_lines <- c(
  summary_lines,
  capture.output(
    print(
      comparison %>%
        dplyr::filter(max_abs_diff >= 1e-9) %>%
        dplyr::select(Variable, Unit, max_abs_diff) %>%
        dplyr::arrange(desc(max_abs_diff), Variable) %>%
        head(40),
      n = 40
    )
  )
)

writeLines(summary_lines, summary_file)
