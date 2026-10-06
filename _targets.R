library(targets)

tar_source("R")
tar_source("scripts/data_processing/clean_targets.R")
tar_source("scripts/data_processing/subsampling_quotas_targets.R")

tar_option_set(
  packages = character(),
  format = "rds",
  error = "stop",
  seed = 20260925L
)

 c(
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
  cleaning_targets,
  subsampling_quotas_targets
)
