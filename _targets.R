library(targets)

tar_source("R")
tar_source("scripts/data_processing/clean_targets.R")

tar_option_set(
  packages = character(),
  format = "rds",
  error = "stop",
  seed = 20260925L
)

append(
  list(
  tar_target(
    description_file,
    "DESCRIPTION",
    format = "file"
  ),
  tar_target(
    package_metadata,
    read.dcf(description_file)[1, c("Package", "Version")]
  )
  ),
  # Keep the cleaning graph in a separate file so its steps are easy to inspect.
  cleaning_targets
)
