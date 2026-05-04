devtools::load_all()

test_data <- data.frame(
  scenario = "Reference",
  region = "China",
  var = c(
    "Primary Energy|Coal|Convert",
    "Primary Energy|Gas|Convert",
    "Primary Energy|Electricity|Coal|w/o CCS",
    "Primary Energy|Coal"
  ),
  year = 2020,
  value = 1:4,
  stringsAsFactors = FALSE
)

cat("Before filter_variables:\n")
print(test_data$var)

# Simulate desired_variables.global
desired_variables.global <<- c("Primary Energy|Coal")

result <- filter_variables(test_data)
cat("\nAfter filter_variables:\n")
print(result$var)
cat("\nNumber of rows:", nrow(result), "\n")
