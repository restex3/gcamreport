# Quick diagnostic: check what regions exist in V8 database
library(gcamreport)
library(rgcam)

conn <- localDBConn("E:/GCAM/GCAM-China_v8/output", "database_basexdb")
cat("Connected to database\n")

# Get queries and run a simple one without region filter
qg <- get("queries_general_vGCAMChina8.0")

# Use population query (simple, should work for any region)
pop_q <- qg[["population by region"]]

cat("Query title:", pop_q$title, "\n")

# Try with empty regions (should return all regions)
tryCatch({
  # Use runQuery directly with no region filter
  table <- rgcam::runQuery(conn, pop_q$query, "Reference", NULL, warn.empty = TRUE)
  cat("Rows returned:", nrow(table), "\n")
  if(nrow(table) > 0) {
    cat("Regions in population data:\n")
    regions <- unique(table$region)
    for(r in sort(regions)) cat("  ", r, "\n")
    cat(sprintf("Total regions: %d\n", length(regions)))
  }
}, error = function(e) {
  cat("Error:", e$message, "\n")
})
