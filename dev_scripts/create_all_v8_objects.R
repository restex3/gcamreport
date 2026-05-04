library(gcamreport)

cat("Creating ALL V8 data objects from V7.1...\n\n")

# Get all V7.1 objects
v71_objs <- ls("package:gcamreport")
v71_objs <- grep("vGCAMChina7\\.1$", v71_objs, value = TRUE)

cat("Found", length(v71_objs), "V7.1 objects\n\n")

# Create V8 versions
v8_list <- list()
for (obj in v71_objs) {
  v8_name <- gsub("7\\.1$", "8\\.0", obj)
  cat("  -", obj, "->", v8_name, "\n")
  v8_list[[v8_name]] <- get(obj)
}

cat("\nSaving", length(v8_list), "objects...\n")
do.call(usethis::use_data, c(v8_list, list(overwrite = TRUE, compress = "xz")))

cat("\nDone!\n")
