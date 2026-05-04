.myGlobals <- new.env(parent = emptyenv())

# GCAM-China Java heap requirement: the nonCO2 query against a 31-province
# BaseX database needs substantial JVM heap.  Set _JAVA_OPTIONS before R
# starts (or at least before rJava initializes the JVM):
#   _JAVA_OPTIONS="-Xmx12g -Xms4g"
#   PATH="C:/Program Files/Java/jre-1.8/bin:$PATH"
#
# The .onLoad hook adds Java to PATH for child processes.
# check_java_heap() warns at runtime if _JAVA_OPTIONS was not set.
.onLoad <- function(libname, pkgname) {
  .myGlobals$ignore.global <- NULL
  .myGlobals$interactive.global <- NULL
  .myGlobals$variables.global <- NULL
  .myGlobals$GCAM_version <- NULL

  # Ensure Java 1.8 is on PATH for rgcam child processes
  java_home <- "C:/Program Files/Java/jre-1.8/bin"
  if (dir.exists(java_home) && !grepl(basename(java_home), Sys.getenv("PATH"), fixed = TRUE)) {
    Sys.setenv(PATH = paste(java_home, Sys.getenv("PATH"), sep = ";"))
  }
}

# Called before generate_report touches any Java-dependent code.
# Warns if _JAVA_OPTIONS is not set (GCAM-China queries may OOM).
check_java_heap <- function() {
  if (Sys.getenv("_JAVA_OPTIONS") == "") {
    warning(
      "_JAVA_OPTIONS is not set. GCAM-China reports with 31+ provinces may\n",
      "  run out of JVM heap during nonCO2 queries.\n",
      "  Set before starting R: _JAVA_OPTIONS=\"-Xmx12g -Xms4g\"\n",
      "  Or set it permanently in your shell profile / system environment.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}
