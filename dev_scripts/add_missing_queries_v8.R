# Add missing queries to queries_general_vGCAMChina8.0
# and fix typo in variables_functions_mapping.csv
library(xml2)
library(gcamreport)

# ------------------------------------------------------------
# 1. Load current queries_general
# ------------------------------------------------------------
queries_general_vGCAMChina8.0 <- get("queries_general_vGCAMChina8.0",
                                      envir = asNamespace("gcamreport"))
cat("Current queries:", length(queries_general_vGCAMChina8.0), "\n")

# ------------------------------------------------------------
# 2. Add "CO2 emissions by sector" from v7.1
# ------------------------------------------------------------
q71 <- get("queries_general_vGCAMChina7.1", envir = asNamespace("gcamreport"))
if ("CO2 emissions by sector" %in% names(q71)) {
  queries_general_vGCAMChina8.0[["CO2 emissions by sector"]] <-
    q71[["CO2 emissions by sector"]]
  cat("Added: CO2 emissions by sector (from v7.1)\n")
}

# ------------------------------------------------------------
# 3. Extract and add queries from Main_queries.xml
#    using rgcam-compatible XML format (aQuery wrapper)
# ------------------------------------------------------------
main_xml <- read_xml("E:/GCAM/GCAM-China_v8/output/queries/Main_queries.xml")

# Build rgcam-compatible XML with aQuery wrapper
build_rgcam_xml <- function(node) {
  paste0(
    '<?xml version="1.0" encoding="UTF-8"?>\n<queries>\n  <aQuery>\n    <all-regions />\n',
    '    ', as.character(node), '\n',
    '  </aQuery>\n</queries>'
  )
}

# Find all nodes with titles
all_nodes <- xml_find_all(main_xml, "//*[@title]")
all_titles <- trimws(xml_attr(all_nodes, "title"))
names(all_nodes) <- all_titles

# Manual title mapping for queries with different names in Main
title_map <- list(
  "elec gen by gen tech (incl cogen)" = "elec gen by gen tech (incl cogen)",  # supplyDemandQuery in Main
  "iron and steel production by tech" = "iron and steel production by tech",  # supplyDemandQuery in Main
  "elec gen by gen tech (cogen only)" = "elec gen by gen tech",               # supplyDemandQuery in Main
  "elec gen by gen tech and vintage (incl cogen)" = "elec gen by gen tech and cooling tech and vintage"  # supplyDemandQuery in Main
)

# Also update existing queries with V8 XPath bodies where available
# (for supplyDemandQuery types that exist in both)
update_from_main <- c(
  "refined liquids production by cooling tech and vintage",
  "hydrogen production by cooling tech and vintage"
)
update_map <- list(
  "refined liquids production by cooling tech and vintage" = "refined liquids production by tech and vintage",
  "hydrogen production by cooling tech and vintage" = "hydrogen production by tech"
)

to_add <- c("elec gen by gen tech (incl cogen)", "iron and steel production by tech",
            "elec gen by gen tech (cogen only)", "elec gen by gen tech and vintage (incl cogen)")

for (nm in to_add) {
  main_title <- title_map[[nm]]
  if (main_title %in% all_titles) {
    node <- all_nodes[[main_title]]
    # Clone and rename
    xml_str <- build_rgcam_xml(node)
    # Replace title in XML string
    xml_str <- gsub(paste0('title="', main_title, '"'),
                    paste0('title="', nm, '"'), xml_str, fixed = TRUE)

    tmp <- tempfile(fileext = ".xml")
    writeLines(xml_str, tmp)
    parsed <- rgcam::parse_batch_query(tmp)
    file.remove(tmp)

    if (nm %in% names(parsed)) {
      queries_general_vGCAMChina8.0[[nm]] <- parsed[[nm]]
      cat("Added from Main:", nm, "<-", main_title, "\n")
    } else {
      cat("FAILED to parse:", nm, "(main title:", main_title, ")\n")
      cat("  Parsed names:", paste(names(parsed), collapse=", "), "\n")
    }
  } else {
    cat("NOT found in Main:", nm, "(searched:", main_title, ")\n")
  }
}

# Update existing queries with V8 XPath bodies
for (nm in names(update_map)) {
  main_title <- update_map[[nm]]
  if (main_title %in% all_titles && nm %in% names(queries_general_vGCAMChina8.0)) {
    node <- all_nodes[[main_title]]
    xml_str <- build_rgcam_xml(node)
    xml_str <- gsub(paste0('title="', main_title, '"'),
                    paste0('title="', nm, '"'), xml_str, fixed = TRUE)

    tmp <- tempfile(fileext = ".xml")
    writeLines(xml_str, tmp)
    parsed <- rgcam::parse_batch_query(tmp)
    file.remove(tmp)

    if (nm %in% names(parsed)) {
      queries_general_vGCAMChina8.0[[nm]] <- parsed[[nm]]
      cat("Updated from Main:", nm, "<-", main_title, "\n")
    } else {
      cat("FAILED to update:", nm, "\n")
    }
  }
}

cat("Final queries count:", length(queries_general_vGCAMChina8.0), "\n")

# ------------------------------------------------------------
# 4. Also rebuild queries_nonCO2 from Main_queries.xml
# ------------------------------------------------------------
cat("\nRebuilding nonCO2 queries...\n")
nonco2_needed <- c(
  "nonCO2 emissions by subsector (excluding resource production)",
  "nonCO2 emissions by region"
)

queries_nonCO2_vGCAMChina8.0 <- list()
for (nm in nonco2_needed) {
  if (nm %in% all_titles) {
    node <- all_nodes[[nm]]
    xml_str <- build_rgcam_xml(node)

    tmp <- tempfile(fileext = ".xml")
    writeLines(xml_str, tmp)
    parsed <- rgcam::parse_batch_query(tmp)
    file.remove(tmp)

    if (nm %in% names(parsed)) {
      queries_nonCO2_vGCAMChina8.0[[nm]] <- parsed[[nm]]
      cat("Added nonCO2:", nm, "\n")
    } else {
      cat("FAILED to parse nonCO2:", nm, "\n")
      cat("  Parsed names:", paste(names(parsed), collapse=", "), "\n")
    }
  } else {
    cat("NOT found in Main:", nm, "\n")
  }
}
cat("NonCO2 queries:", length(queries_nonCO2_vGCAMChina8.0), "\n")

# ------------------------------------------------------------
# 5. Save
# ------------------------------------------------------------
cat("\nSaving...\n")
usethis::use_data(
  queries_general_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)
usethis::use_data(
  queries_nonCO2_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

# ------------------------------------------------------------
# 6. Fix typos in variables_functions_mapping.csv
# ------------------------------------------------------------
csv_path <- "inst/extdata/mappings/GCAMChina8.0/variables_functions_mapping.csv"
csv_content <- readLines(csv_path)

# Fix "fue" -> "fuel" typo
if (any(grepl("industry final energy by tech and fue", csv_content, fixed = TRUE))) {
  csv_content <- gsub("industry final energy by tech and fue",
                      "industry final energy by tech and fuel",
                      csv_content, fixed = TRUE)
  writeLines(csv_content, csv_path)
  cat("Fixed typo in CSV: fue -> fuel\n")
} else {
  cat("CSV typo already fixed or not found\n")
}

cat("\nDone!\n")
cat("Next: source('dev_scripts/rebuild_package_v8.R')\n")
