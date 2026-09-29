test_that("epmebiot package loads for testing", {
  expect_true(isNamespaceLoaded("epmebiot"))
})

test_that("PBDB URL is correct", {
  expect_equal(
    get_pbdb_url(
      "Capitanian",
      "Norian",
      "siliciclastic, mixed, carbonate",
      paste(
        "marine, carbonate, silicic, marginal, reef, stshallow, stdeep,",
        "offshore, slope, basin, marindet"
      ),
      "strat, lith, env, entname"
    ),
    paste0(
      "https://paleobiodb.org/data1.2/occs/list.txt?",
      "datainfo&rowcount&idqual=certain&pres=regular",
      "&interval=Capitanian,Norian",
      "&lithology=siliciclastic,mixed,carbonate",
      paste0(
        "&envtype=marine,carbonate,silicic,marginal,reef,stshallow,",
        "stdeep,offshore,slope,basin,marindet"
      ),
      "&pgm=gplates&show=full,strat,lith,env,entname"
    )
  )
})

test_that("PBDB data are downloaded to a CSV file", {
  output_file = tempfile(fileext = ".csv")
  on.exit(unlink(output_file))
  downloaded_url = NULL

  # Mocking...
  local_mocked_bindings(
    download_pbdb_file = function(url, output_file) {
      downloaded_url <<- url
      writeLines(
        c("occurrence_no,accepted_name", "1,Rhynchonella"),
        output_file
      )
      0L
    },
    .package = "epmebiot"
  )

  result = get_pbdb_data(
    "Capitanian",
    "Norian",
    "siliciclastic",
    "marine",
    "strat",
    output_file = output_file
  )

  expect_identical(result, normalizePath(output_file, mustWork = TRUE))
  expect_true(file.exists(result))
  expect_equal(
    utils::read.csv(result),
    data.frame(occurrence_no = 1L, accepted_name = "Rhynchonella")
  )
  expect_equal(
    downloaded_url,
    get_pbdb_url(
      "Capitanian",
      "Norian",
      "siliciclastic",
      "marine",
      "strat"
    )
  )
})

test_that("PBDB output must use a CSV extension", {
  expect_error(
    get_pbdb_data("Capitanian", "Norian", "siliciclastic", "marine", "strat",
                  output_file = tempfile(fileext = ".txt")),
    "must have a .csv extension",
    fixed = TRUE
  )
})
