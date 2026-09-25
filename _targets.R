library(targets)

tar_option_set(
  packages = character(),
  format = "rds",
  error = "stop",
  seed = 20260925L
)

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
)
