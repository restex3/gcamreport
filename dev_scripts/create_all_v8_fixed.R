library(gcamreport)

cat("Creating ALL V8 data objects from V7.1...\n\n")

v71_objs <- ls("package:gcamreport")
v71_objs <- grep("vGCAMChina7\\.1$", v71_objs, value = TRUE)

cat("Found", length(v71_objs), "V7.1 objects\n\n")

for (obj in v71_objs) {
  v8_name <- gsub("7\\.1$", "8\\.0", obj)
  cat("  Creating", v8_name, "...")
  
  # Assign to global env
  assign(v8_name, get(obj), envir = .GlobalEnv)
  
  # Save
  do.call(usethis::use_data, list(as.name(v8_name), overwrite = TRUE, compress = "xz"))
  
  cat(" done\n")
}

cat("\nAll done!\n")
