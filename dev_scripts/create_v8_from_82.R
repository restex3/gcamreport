library(gcamreport)

cat("Creating ALL V8 data objects from GCAM 8.2...\n\n")

# Get all v8.2 objects
v82_objs <- ls("package:gcamreport")
v82_objs <- grep("_v8\\.2$", v82_objs, value = TRUE)

cat("Found", length(v82_objs), "v8.2 objects\n\n")

# Create GCAMChina8.0 versions
for (obj in v82_objs) {
  v8china_name <- gsub("_v8\\.2$", "_vGCAMChina8.0", obj)
  cat("  Creating", v8china_name, "...")
  
  # Assign to global env
  assign(v8china_name, get(obj), envir = .GlobalEnv)
  
  # Save
  do.call(usethis::use_data, list(as.name(v8china_name), overwrite = TRUE, compress = "xz"))
  
  cat(" done\n")
}

cat("\nAll", length(v82_objs), "objects created!\n")
