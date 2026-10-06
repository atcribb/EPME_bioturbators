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

test_that("trim_columns returns only the requested columns", {
  input_data <- data.frame(
    occurrence_no = 1:2,
    accepted_name = c("A", "B"),
    extra_column = c(TRUE, FALSE)
  )

  result <- trim_columns(
    input_data,
    cols_list = c("accepted_name", "occurrence_no")
  )

  expect_identical(names(result), c("accepted_name", "occurrence_no"))
  expect_identical(result$accepted_name, input_data$accepted_name)
  expect_identical(result$occurrence_no, input_data$occurrence_no)
})

test_that("trim_columns rejects blank column selections without warnings", {
  input_data <- data.frame(occurrence_no = 1:2)

  expect_error(
    expect_no_warning(trim_columns(input_data, cols_list = character())),
    "Kept columns is blank or zero",
    fixed = TRUE
  )
  expect_error(
    expect_no_warning(trim_columns(input_data, cols_list = NA)),
    "Kept columns is blank or zero",
    fixed = TRUE
  )
})

test_that("Only wanted columns are being kept", {

  # Test that manual columns are being entered
  expect_equal(trim_columns(data.frame(a=1, b=2, c=3, d=4), c("a", "c")),
               data.frame(a=1,c=3))

  expect_error(trim_columns(data.frame(a=1,b=2,c=3,d=4)),
  "Kept columns is blank or zero. Add desired columns to keep.")

})

test_that("taxonomic_clean keeps only eligible marine taxa", {
  input_data <- data.frame(
    accepted_rank = c("genus", "species", "family", "genus", "genus"),
    genus = c("G1", "G2", "G3", "", "G5"),
    phylum = c("Brachiopoda", "Chordata", "Brachiopoda", "Brachiopoda", "Porifera"),
    class = c("", "", "", "", ""),
    order = c("", "", "", "", ""),
    family = c("", "", "", "", ""),
    stringsAsFactors = FALSE
  )

  test_result <- taxonomic_clean(input_data)

  expect_equal(test_result$genus, c("G1", "G5"))
  expect_equal(test_result$clgen, c(" G1", " G5"))
  expect_false(any(test_result$accepted_rank == "family"))
  expect_false(any(test_result$genus == ""))
})

test_that("environment_clean removes terrestrial environments only", {
  input_data <- data.frame(
    environment = c("marine", "alluvial fan", "offshore", "lacustrine indet.", NA),
    occurrence_no = 1:5,
    stringsAsFactors = FALSE
  )

  test_result <- environment_clean(input_data)

  expect_equal(test_result$occurrence_no, c(1L, 3L, 5L))
  expect_equal(test_result$environment, c("marine", "offshore", NA_character_))
})

test_that("assign_paleoenvironments classifies lithology and bathymetry", {
  skip_if_not_installed("divDyn")

  input_data <- data.frame(
    lithology1 = c("sandstone", "limestone", "sandstone", "lime mudstone", "carbonate",
                   "shale", "siliciclastic", "reef rocks"),
    environment = c("shoreface", "offshore", "unknown environment", "unknown environment", "shoreface",
                    "basinal (siliciclastic)", "shoreface", "reef, buildup or bioherm"),
    stringsAsFactors = FALSE
  )

  test_result <- assign_paleoenvironments(input_data)

  expect_equal(test_result$lith, c("siliciclastic", "carbonate", "siliciclastic", "carbonate", "carbonate", "siliciclastic", "siliciclastic", "carbonate"))
  expect_equal(test_result$bath, c("shallow", "deep", "unknown", "unknown", "shallow", "deep", "shallow", "shallow"))
  expect_equal(
    test_result$paleoenvironment,
    c("shallow_siliciclastic", "deep_carbonate", "unclass_siliciclastic", "unclass_carbonate", "shallow_carbonate",
      "deep_siliciclastic", "shallow_siliciclastic", "shallow_carbonate")
  )
})

test_that('midpoint_stage_lookup matches the right midpoints', {
  skip_if_not_installed("deeptime")

  test_input <- apply(deeptime::stages[,c('max_age','min_age')], 1, mean)
  test_return <- deeptime::stages$name

  expect_equal(sapply(test_input,midpoint_stage_lookup),
               test_return)


})

test_that('get_palaeocoordinates stops when it is supposed to',{

  test_one <- data.frame(occurrences=c('Rhynchonella','Rhynchonella'),
                         lng=c(-84, -84),
                         lat=c(36, 36))
  expect_error(get_palaeocoordinates(test_one),
               "The input data is missing required columns: bin_midpoint.")

  test_two <- data.frame(occurrences=c('Rhynchonella','Rhynchonella'),
                         bin_midpoint=c(355, 355))
  expect_error(get_palaeocoordinates(test_two),
               "The input data is missing required columns: lng, lat.")

  test_three <- data.frame(occurrences=c('Rhynchonella','Rhynchonella'),
                            lng=c(-84, -84),
                            lat=c(36, 36),
                            bin_midpoint=c(355, 355))
  test_return <- palaeorotate(test_three, lng='lng', lat='lat', age='bin_midpoint', model='PALEOMAP', method='point')
  expect_equal(get_palaeocoordinates(test_three),
               test_return)

})

test_that('messy data gets squeaky clean', {

  test_input <- data.frame(
    occurrences=c('Rhynchonella','Rhynchonella','Rhynchonella','Rhynchonella','Rhynchonella'),
    formation=c('Fort Payne Fm', 'Fort Payne', NA, NA, 'Fort Payne Formation'),
    p_lat=c(36.9, NA, NA, 36.8, 36.7),
    p_lng=c(-84.1, NA, NA, -84.2, -84.3)
  )
  test_return <- test_input[c(1,5),]

  expect_equal(get_squeaky_clean(test_input, report=FALSE), test_return)

})
