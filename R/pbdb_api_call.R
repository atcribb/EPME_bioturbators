# Return data from a Paleobiology Database API call.

# Generate a PBDB url
get_pbdb_url <- function(StartInterval, EndInterval, Lithologies, Environments,
                         Outputs) {
  interval <- paste(StartInterval, EndInterval, sep = ",")
  lithology <- gsub("\\s", "", tolower(Lithologies))
  environment <- gsub("\\s", "", tolower(Environments))
  outputs <- paste("full", gsub("\\s", "", tolower(Outputs)), sep = ",")

  paste0(
    "https://paleobiodb.org/data1.2/occs/list.txt?",
    "datainfo&rowcount&idqual=certain&pres=regular",
    "&interval=", interval,
    "&lithology=", lithology,
    "&envtype=", environment,
    "&pgm=gplates",
    "&show=", outputs
  )
}

# Download function
download_pbdb_file <- function(url, output_file) {
  utils::download.file(url, output_file, mode = "wb", quiet = TRUE)
}

# Higher order PBDB data call function
get_pbdb_data <- function(StartInterval, EndInterval, Lithologies, Environments,
                          Outputs,
                          output_file = tempfile("pbdb_", fileext = ".csv")) {

  # Check that output file is a file path
  if (!is.character(output_file) || length(output_file) != 1L || is.na(output_file) || !nzchar(output_file)) {
    stop("`output_file` must be a single, non-empty file path.", call. = FALSE)
  }

  # Check that output file is a .csv
  if (tolower(tools::file_ext(output_file)) != "csv") {
    stop("`output_file` must have a .csv extension.", call. = FALSE)
  }

  # Generate URL
  url <- get_pbdb_url(
    StartInterval,
    EndInterval,
    Lithologies,
    Environments,
    Outputs
  )


  status <- download_pbdb_file(url, output_file)

  if (!identical(status, 0L) || !file.exists(output_file)) {
    stop("The PBDB data could not be downloaded.", call. = FALSE) #Raise an error if the file download was not successful
  }

  normalizePath(output_file, mustWork = TRUE)

}
