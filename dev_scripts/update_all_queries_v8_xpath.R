# Update ALL queries in queries_general_vGCAMChina8.0 with V8 XPath bodies
# where equivalents exist as supplyDemandQuery in Main_queries.xml
library(xml2)
library(gcamreport)

main_xml <- read_xml("E:/GCAM/GCAM-China_v8/output/queries/Main_queries.xml")

# Build rgcam-compatible XML wrapper
build_rgcam_xml <- function(node) {
  paste0(
    '<?xml version="1.0" encoding="UTF-8"?>\n<queries>\n  <aQuery>\n    <all-regions />\n',
    '    ', as.character(node), '\n',
    '  </aQuery>\n</queries>'
  )
}

# Get ALL nodes with titles
all_nodes <- xml_find_all(main_xml, "//*[@title]")
all_titles <- trimws(xml_attr(all_nodes, "title"))
names(all_nodes) <- all_titles

# Get current queries
qg <- get("queries_general_vGCAMChina8.0", envir = asNamespace("gcamreport"))
current_names <- names(qg)

# Title mappings from gcamreport names to Main names
# This covers all-known differences in naming
title_map <- list(
  "CO2 emissions by resource production" = "CO2 emissions by resource production ",

  # "cooling tech and vintage" variants -> use tech and vintage
  "refined liquids production by cooling tech and vintage" = "refined liquids production by tech and vintage",
  "hydrogen production by cooling tech and vintage" = "hydrogen production by tech",

  # CO2 emissions by sector -> use excluding resource production version
  "CO2 emissions by sector" = "CO2 emissions by sector (excluding resource production)",

  # Elec variants
  "elec gen by gen tech (cogen only)" = "elec gen by gen tech",
  "elec gen by gen tech and vintage (incl cogen)" = "elec gen by gen tech and cooling tech and vintage",

  # Aggregated land allocation might be named differently
  "aggregated land allocation" = "aggregated land allocation",

  # The rest should be exact matches
  "CO2 emissions by sector (excluding resource production)" = "CO2 emissions by sector (excluding resource production)",
  "CO2 emissions by sector (no bio) (excluding resource production)" = "CO2 emissions by sector (no bio) (excluding resource production)"
)

# For queries that exist in Main as supplyDemandQuery, update with V8 XPath
# For other query types (emissionsQueryBuilder, etc.), keep the v7.1 version
updated_count <- 0
kept_count <- 0
failed_count <- 0

for (nm in current_names) {
  # Determine what Main title to search for
  main_search <- if (nm %in% names(title_map)) title_map[[nm]] else nm

  if (main_search %in% all_titles) {
    node <- all_nodes[[main_search]]
    node_type <- xml_name(node)

    if (node_type == "supplyDemandQuery") {
      # Build XML with V8 XPath
      xml_str <- build_rgcam_xml(node)
      xml_str <- gsub(paste0('title="', main_search, '"'),
                      paste0('title="', nm, '"'), xml_str, fixed = TRUE)

      tmp <- tempfile(fileext = ".xml")
      writeLines(xml_str, tmp)
      parsed <- try(rgcam::parse_batch_query(tmp), silent = TRUE)
      file.remove(tmp)

      if (!inherits(parsed, "try-error") && nm %in% names(parsed)) {
        qg[[nm]] <- parsed[[nm]]
        updated_count <- updated_count + 1
      } else {
        cat(sprintf("FAILED: %s (%s)\n", nm, node_type))
        failed_count <- failed_count + 1
      }
    } else {
      # Keep v7.1 version for non-supplyDemandQuery types
      kept_count <- kept_count + 1
    }
  } else {
    # Not in Main - keep v7.1 version (it was crafted for rgcam compatibility)
    kept_count <- kept_count + 1
  }
}

cat(sprintf("Updated with V8 XPath: %d\n", updated_count))
cat(sprintf("Kept v7.1 version: %d\n", kept_count))
cat(sprintf("Failed to update: %d\n", failed_count))
cat(sprintf("Total queries: %d\n", length(qg)))

# Save
queries_general_vGCAMChina8.0 <- qg
usethis::use_data(
  queries_general_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("\nDone! Updated queries saved.\n")
