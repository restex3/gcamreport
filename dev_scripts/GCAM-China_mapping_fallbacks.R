fb <- get(".myGlobals", asNamespace("gcamreport"))$mapping_fallbacks
fb_df <- dplyr::bind_rows(lapply(names(fb), function(n) {
  dplyr::mutate(fb[[n]], mapping = n)
}))
write.csv(fb_df,
          "e:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/mapping_fallbacks.csv",
          row.names = FALSE)
