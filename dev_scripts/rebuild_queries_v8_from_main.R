# Rebuild queries_general_vGCAMChina8.0 and queries_nonCO2_vGCAMChina8.0
# from GCAM China 8.0's Main_queries.xml
# This ensures the XPath query bodies match V8 database structure

library(xml2)
library(gcamreport)

main_xml_path <- "E:/GCAM/GCAM-China_v8/output/queries/Main_queries.xml"
cat("Reading Main_queries.xml...\n")
main_xml <- read_xml(main_xml_path)

# Extract all nodes with title attributes (keep original titles, including trailing spaces)
all_nodes <- xml_find_all(main_xml, "//*[@title]")
all_titles_orig <- xml_attr(all_nodes, "title")
all_titles_trimmed <- trimws(all_titles_orig)
cat(sprintf("Total queries in Main: %d (unique titles: %d)\n",
            length(all_nodes), length(unique(all_titles_trimmed))))

# Build a lookup: trimmed title -> original title
# For duplicates, prefer the supplyDemandQuery version
trimmed_to_orig <- list()
for (i in seq_along(all_titles_trimmed)) {
  t <- all_titles_trimmed[i]
  if (!t %in% names(trimmed_to_orig)) {
    trimmed_to_orig[[t]] <- all_titles_orig[i]
  }
}

# Also build lookup: trimmed_title -> node index
title_to_node <- list()
for (i in seq_along(all_titles_trimmed)) {
  t <- all_titles_trimmed[i]
  if (!t %in% names(title_to_node)) {
    title_to_node[[t]] <- i  # store index of first occurrence
  }
}

# ------------------------------------------------------------
# Build the complete list of query names needed by gcamreport
# ------------------------------------------------------------
q_old <- get("queries_general_vGCAMChina8.0")
old_general_names <- names(q_old)

q_nonco2_old <- get("queries_nonCO2_vGCAMChina8.0")
old_nonco2_names <- names(q_nonco2_old)

vf <- read.csv("inst/extdata/mappings/GCAMChina8.0/variables_functions_mapping.csv",
               sep = ";", stringsAsFactors = FALSE)
csv_queries <- character(0)
for (i in 1:nrow(vf)) {
  qs <- trimws(strsplit(vf$queries[i], ",")[[1]])
  csv_queries <- c(csv_queries, qs[qs != ""])
}
csv_queries <- unique(csv_queries)

all_needed <- unique(c(old_general_names, old_nonco2_names, csv_queries))
cat(sprintf("Total unique needed: %d\n", length(all_needed)))

# ------------------------------------------------------------
# Manual title mapping: needed_name -> Main_queries.xml trimmed title
# ------------------------------------------------------------
title_map <- list(
  # "cooling tech and vintage" -> "tech and vintage" (Main doesn't have cooling variants)
  "refined liquids production by cooling tech and vintage" = "refined liquids production by tech and vintage",

  # No hydrogen vintage query in V8 Main - use basic hydrogen production
  "hydrogen production by cooling tech and vintage" = "hydrogen production by tech",

  # "CO2 emissions by sector" (without excluding) -> use excluding version
  "CO2 emissions by sector" = "CO2 emissions by sector (excluding resource production)",

  # elec gen cogen only -> use standard elec gen by gen tech
  "elec gen by gen tech (cogen only)" = "elec gen by gen tech",

  # elec gen vintage incl cogen -> use cooling tech and vintage (equivalent)
  "elec gen by gen tech and vintage (incl cogen)" = "elec gen by gen tech and cooling tech and vintage",

  # CSV typo "fue" -> "fuel"
  "industry final energy by tech and fue" = "industry final energy by tech and fuel"
)

# ------------------------------------------------------------
# Resolve each needed name to a Main node
# ------------------------------------------------------------
needed_to_node <- list()
not_found <- c()
manual_count <- 0
auto_count <- 0

for (nm in all_needed) {
  search_title <- NULL

  if (nm %in% names(title_map)) {
    search_title <- title_map[[nm]]
    manual_count <- manual_count + 1
  } else if (nm %in% all_titles_trimmed) {
    search_title <- nm  # exact match
  } else if (nm %in% all_titles_orig) {
    search_title <- trimws(nm)
  } else {
    # Fuzzy match
    best <- all_titles_trimmed[which.min(adist(nm, all_titles_trimmed))]
    search_title <- best
    auto_count <- auto_count + 1
    cat(sprintf("AUTO: '%s' -> '%s' (dist=%d)\n", nm, best, adist(nm, best)[1,1]))
  }

  if (search_title %in% names(title_to_node)) {
    needed_to_node[[nm]] <- all_nodes[[title_to_node[[search_title]]]]
  } else {
    cat(sprintf("NOT FOUND: '%s' (searched for '%s')\n", nm, search_title))
    not_found <- c(not_found, nm)
  }
}

cat(sprintf("\nManual mappings: %d, Auto: %d, Not found: %d\n",
            manual_count, auto_count, length(not_found)))

# ------------------------------------------------------------
# Build an XML string for parsing by rgcam
# ------------------------------------------------------------
build_query_xml <- function(node_list, title_map_names = NULL) {
  lines <- c('<?xml version="1.0" encoding="UTF-8"?>', '<queries>')

  for (nm in names(node_list)) {
    node <- node_list[[nm]]
    # Convert node to XML text
    node_text <- as.character(node)
    # Replace the original title with the needed name
    # The title attribute appears as title="original title"
    orig_title <- xml_attr(node, "title")
    # Escape for regex
    node_text <- sub(
      paste0('title="', orig_title, '"'),
      paste0('title="', nm, '"'),
      node_text,
      fixed = TRUE
    )
    lines <- c(lines, node_text)
  }

  lines <- c(lines, '</queries>')
  paste(lines, collapse = "\n")
}

# ------------------------------------------------------------
# Build GENERAL queries
# ------------------------------------------------------------
cat("\n--- Building GENERAL queries ---\n")

# Get the nodes for old general query names
general_nodes <- list()
for (nm in old_general_names) {
  if (nm %in% names(needed_to_node)) {
    general_nodes[[nm]] <- needed_to_node[[nm]]
  } else {
    cat(sprintf("  SKIP: '%s'\n", nm))
  }
}

# Add additional queries from CSV that are not in general or nonCO2
for (nm in csv_queries) {
  if (!nm %in% old_general_names && !nm %in% old_nonco2_names) {
    if (nm %in% names(needed_to_node)) {
      general_nodes[[nm]] <- needed_to_node[[nm]]
      cat(sprintf("  ADDED from CSV: '%s'\n", nm))
    } else {
      cat(sprintf("  CSV query not found: '%s'\n", nm))
    }
  }
}
cat(sprintf("General queries: %d\n", length(general_nodes)))

# Build XML and parse
general_xml_str <- build_query_xml(general_nodes)
tmp_general <- tempfile(fileext = ".xml")
writeLines(general_xml_str, tmp_general)
cat(sprintf("Temp XML: %s (%d bytes)\n", tmp_general, nchar(general_xml_str)))

cat("Parsing with rgcam...\n")
queries_general_vGCAMChina8.0 <- rgcam::parse_batch_query(tmp_general)
cat(sprintf("Parsed %d general queries\n", length(queries_general_vGCAMChina8.0)))

# ------------------------------------------------------------
# Build NONCO2 queries
# ------------------------------------------------------------
cat("\n--- Building NONCO2 queries ---\n")

nonco2_nodes <- list()
for (nm in old_nonco2_names) {
  if (nm %in% names(needed_to_node)) {
    nonco2_nodes[[nm]] <- needed_to_node[[nm]]
  }
}
cat(sprintf("NonCO2 queries: %d\n", length(nonco2_nodes)))

nonco2_xml_str <- build_query_xml(nonco2_nodes)
tmp_nonco2 <- tempfile(fileext = ".xml")
writeLines(nonco2_xml_str, tmp_nonco2)

cat("Parsing with rgcam...\n")
queries_nonCO2_vGCAMChina8.0 <- rgcam::parse_batch_query(tmp_nonco2)
cat(sprintf("Parsed %d nonCO2 queries\n", length(queries_nonCO2_vGCAMChina8.0)))

# ------------------------------------------------------------
# Verify coverage
# ------------------------------------------------------------
cat("\n--- Verification ---\n")
missing_csv <- c()
for (nm in csv_queries) {
  in_general <- nm %in% names(queries_general_vGCAMChina8.0)
  in_nonco2 <- nm %in% names(queries_nonCO2_vGCAMChina8.0)
  if (!in_general && !in_nonco2) {
    cat(sprintf("CSV query MISSING: '%s'\n", nm))
    missing_csv <- c(missing_csv, nm)
  }
}
cat(sprintf("CSV queries covered: %d / %d\n",
            length(csv_queries) - length(missing_csv), length(csv_queries)))

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------
cat("\nSaving queries_general_vGCAMChina8.0.rda...\n")
usethis::use_data(
  queries_general_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("Saving queries_nonCO2_vGCAMChina8.0.rda...\n")
usethis::use_data(
  queries_nonCO2_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

# Clean up
file.remove(tmp_general, tmp_nonco2)

cat("\n=== DONE ===\n")
cat("Next: fix 'fue' typo in variables_functions_mapping.csv\n")
cat("Then rebuild package: source('dev_scripts/rebuild_package_v8.R')\n")
