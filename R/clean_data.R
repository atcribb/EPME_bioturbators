# Functions to clean raw pbdb data
library(divDyn)


# Remove unwanted columns to reduce data size
trim_columns <- function(dat, cols_list=NA, Standard_Long=FALSE, Standard_Short=FALSE){

  #Return errors for bad inputs
  if(Standard_Long==TRUE && Standard_Short==TRUE ||
     Standard_Long==TRUE && Standard_Short==TRUE && !is.na(cols_list)){
    stop("Too many column options. Select only standard long or standard short, or input your own column list.")
  }
  if(Standard_Long==TRUE && !is.na(cols_list) ||
     Standard_Short==TRUE && !is.na(cols_list)){
    stop("Too many column inputs. Only ask for one standard output OR your own column list.")
  }
  if(Standard_Long==TRUE && is.na(cols_list)){
    keep_cols <- c('occurrence_no', 'collection_no', 'identified_name', 'identified_rank', 'accepted_name', 'accepted_attr', 'accepted_rank',
                   'early_interval', 'late_interval', 'max_ma', 'min_ma', 'reference_no',
                   'phylum', 'class', 'order', 'family', 'genus', 'abund_value', 'abund_unit',
                   'collection_name', 'lng', 'lat', 'latlng_basis', 'paleomodel', 'geogscale',
                   'formation', 'geological_group', 'member', 'stratscale', 'zone', 'zone_type',
                   'lithology1', 'lithology2', 'minor_lithology2', 'environment', 'pres_mode', 'taxon_environment',
                   'motility', 'life_habit', 'vision', 'diet', 'composition'
                   )
  }else if (Standard_Short==TRUE && is.na(cols_list)){
    keep_cols <- c('occurrence_no', 'collection_no', 'collection_name', 'accepted_name',
                   'early_interval', 'late_interval', 'max_ma', 'min_ma', 'reference_no',
                   'phylum', 'class', 'order', 'family', 'genus',
                   'lng', 'lat', 'formation', 'geological_group', 'member',
                   'lithology1', 'environment', 'motility', 'life_habit', 'diet', 'composition')
  } else{
    keep_cols <- cols_list
  }

  #Return error if keep_cols is bull
  if(length(keep_cols) == 0L || all(is.na(keep_cols))){
    stop("Kept columns is blank or zero. Add desired columns to keep.")
  }

  dat_short = dat[,keep_cols]
  return(dat_short)

}

# Clean at the taxonomic level - follows ddPhanero cleaning protocols
taxonomic_clean <- function(dat){

  #Following ddPhanero (Kocscis et al.)
  #==== Taxonomic Filtering =====#
  #omit occurrences not identified to genus level
  dat <- subset(dat, accepted_rank %in% c('genus', 'species'))
  dat <- dat[dat$genus!='',]

  #phyla-level filtering
  marine.phyla <- c("",
                    "Agmata",
                    "Annelida",
                    "Bilateralomorpha",
                    "Brachiopoda",
                    "Bryozoa",
                    "Calcispongea",
                    "Chaetognatha",
                    "Cnidaria",
                    "Ctenophora",
                    "Echinodermata",
                    "Entoprocta",
                    "Foraminifera",
                    "Hemichordata",
                    "Hyolitha",
                    "Mollusca",
                    "Nematoda",
                    "Nematomorpha",
                    "Nemertina",
                    "Onychophora",
                    "Petalonamae",
                    "Phoronida",
                    "Platyhelminthes",
                    "Porifera",
                    "Rhizopodea",
                    "Rotifera",
                    "Sarcomastigophora",
                    "Sipuncula",
                    "Uncertain",
                    "Vetulicolia",
                    "")
  select.phyla <- (dat$phylum %in% marine.phyla) #logical vector of where phyla of interest are

  #class-level filtering
  marine.class <- c(
    "Acanthodii",
    "Actinopteri",
    "Actinopterygii",
    "Agnatha",
    "Cephalaspidomorphi",
    "Chondrichthyes",
    "Cladistia",
    "Coelacanthimorpha",
    "Conodonta",
    "Galeaspida",
    "Myxini",
    "Osteichthyes",
    "Petromyzontida",
    "Plagiostomi",
    "Pteraspidomorphi",
    "Artiopoda",
    "Branchiopoda",
    "Cephalocarida",
    "Copepoda",
    "Malacostraca",
    "Maxillopoda",
    "Megacheira",
    "Merostomoidea",
    "Ostracoda",
    "Paratrilobita",
    "Pycnogonida",
    "Remipedia",
    "Thylacocephala",
    "Trilobita",
    "Xiphosura"
  )
  select.class <- (dat$class %in% marine.class) #logical vector of where classes of interest are

  #filtering for mammals
  marine.mammals.order <- c('Cetacea', 'Sirenia')
  select.mammals.order <- (dat$order %in% marine.mammals.order)

  #and mammalian carnivores
  marine.mammals.family <- c("Otariidae", "Phocidae", "Desmatophocidae")
  select.mammals.family <- (dat$family %in% marine.mammals.family)

  #filtering for marine reptiles
  marine.reptiles.order <- c("Eosauropterygia",
                             "Hupehsuchia",
                             "Ichthyosauria",
                             "Placodontia",
                             "Sauropterygia",
                             "Thalattosauria")
  select.marine.reptiles <- (dat$order %in% marine.reptiles.order)

  #filtering for sea turtles
  turtles.family <- c("Cheloniidae",
                      "Protostegidae",
                      "Dermochelyidae",
                      "Dermochelyoidae",
                      "Toxochelyidae",
                      "Pancheloniidae")
  select.turtles <- (dat$family %in% turtles.family)

  #finally, subset this data with the multiple filters
  taxacleaned_dat <- dat[select.phyla | select.class | select.mammals.order | select.mammals.family | select.marine.reptiles | select.turtles ,]

  #resolve homonymies by combining class names and genus names to create individual entries
  taxacleaned_dat$clgen <- paste(taxacleaned_dat$class, taxacleaned_dat$genus)

  return(taxacleaned_dat)

}

# Clean at the environmental level - follows ddPhanero cleaning protocols
environment_clean <- function(dat){

  #remove occurrences in environments that are more likely to be terrestrial taxa (bloat n float)
  omit.environments <- c(
    "\"floodplain\"", "alluvial fan", "cave", "\"channel\"", "channel lag" ,
    "coarse channel fill", "crater lake", "crevasse splay", "dry floodplain",
    "delta plain", "dune", "eolian indet.", "fine channel fill", "fissure fill",
    "fluvial indet.", "fluvial-lacustrine indet.", "fluvial-deltaic indet.",
    "glacial", "interdune", "karst indet.", "lacustrine - large",
    "lacustrine - small", "lacustrine delta front", "lacustrine delta plain",
    "lacustrine deltaic indet.", "lacustrine indet.",
    "lacustrine interdistributary bay", "lacustrine prodelta", "levee", "loess",
    "mire/swamp", "pond", "sinkhole", "spring", "tar", "terrestrial indet.",
    "wet floodplain")
  envclean_data <- subset(dat, !(environment %in% omit.environments)) #removal

  #add environment keys



return(envclean_data)

}

# Select palaeoenvironments - follow ddPhanero keys guide
assign_paleoenvironments <- function(dat){

  # Defense! Defense!
  if(!requireNamespace("divDyn", quietly=TRUE)){
    stop("The divDyn package is required. Install it with install.packages(\"divDyn\")")
  } else{
    library(divDyn)
    data(keys, package="divDyn")
    }

  required_cols <- c("lithology1", "environment")
  missing_cols <- setdiff(required_cols, colnames(dat))
  if (length(missing_cols) > 0L){
    stop("The input data is missing either lithology1 or environment column.")
  }

  # PBDB values can contain literal quotation marks, inconsistent case, or surrounding whitespace. Normalize them to match the divDyn keys exactly.
  normalize_pbdb_value <- function(x) {
    x <- tolower(trimws(as.character(x)))
    x <- gsub('^["\']+|["\']+$', "", x)
    x[x %in% c("", "na", "n/a", "null")] <- NA_character_
    x
  }

  lithology <- normalize_pbdb_value(dat$lithology1)
  environment <- normalize_pbdb_value(dat$environment)
  lithology_keys <- lapply(keys$lith, normalize_pbdb_value)
  environment_keys <- lapply(keys$bath, normalize_pbdb_value)

  # Assign environmental variables using the normalized PBDB values.
  dat$lith <- categorize(lithology, lithology_keys)
  dat$bath <- categorize(environment, environment_keys)

  #give those paleoenvironments
  dat$paleoenvironment <- rep(NA, nrow(dat))
  dat[which(dat$lith=='siliciclastic' & dat$bath=='shallow'),'paleoenvironment'] <- 'shallow_siliciclastic'
  dat[which(dat$lith=='siliciclastic' & dat$bath=='deep'),'paleoenvironment'] <- 'deep_siliciclastic'
  dat[which(dat$lith=='siliciclastic' & dat$bath=='unknown'),'paleoenvironment'] <- 'unclass_siliciclastic'
  dat[which(dat$lith=='carbonate' & dat$bath=='shallow'),'paleoenvironment'] <- 'shallow_carbonate'
  dat[which(dat$lith=='carbonate' & dat$bath=='deep'),'paleoenvironment'] <- 'deep_carbonate'
  dat[which(dat$lith=='carbonate' & dat$bath=='unknown'),'paleoenvironment'] <- 'unclass_carbonate'

  return(dat)

}


midpoint_stage_lookup <- function(midpoint){

  if (!is.numeric(midpoint) || length(midpoint) != 1L || is.na(midpoint)) {
    stop("`midpoint` must be one non-missing numeric value.", call. = FALSE)
  }

  if(!requireNamespace("deeptime", quietly=TRUE)){
    stop("The deeptime package is required. Install it with install.packages(\"deeptime\")")
  } else{
    library(deeptime)
    data(stages, package="deeptime")
  }

  # `deeptime::stages` uses max_age/min_age/name. Support the equivalent bottom/top/stage names used by older versions of the table as well.
  if (all(c("max_age", "min_age", "name") %in% names(stages))) {
    older_age <- stages$max_age
    younger_age <- stages$min_age
    stage_names <- stages$name
    stage_matches <- function(x, older, younger) {
      x >= younger && x < older
    }
  } else if (all(c("bottom", "top", "stage") %in% names(stages))) {
    older_age <- stages$bottom
    younger_age <- stages$top
    stage_names <- stages$stage
    stage_matches <- function(x, older, younger) {
      x > younger && x <= older
    }
  } else {
    stop("The deeptime stages table has an unsupported column structure.", call. = FALSE)
  }

  check <- "not yet"
  stage_match <- NA
  stage_no <- 1
  while(check == "not yet" && stage_no <= nrow(stages)){
    if(!is.na(older_age[stage_no]) && !is.na(younger_age[stage_no]) && stage_matches(midpoint, older_age[stage_no], younger_age[stage_no])){
      stage_match <- stage_names[stage_no]
      check <- "found it"
    } else{
      stage_no <- stage_no + 1
    }
  }

  return(stage_match)

}

# Stratigraphic binning - palaeoverse functions
bin_stages <- function(dat, early_stage, late_stage){

  # Defense!!!
  if (!is.data.frame(dat) || nrow(dat) == 0L) {
    stop("`dat` must be a non-empty data frame.", call. = FALSE)
  }
  if(!requireNamespace("palaeoverse", quietly=TRUE)){
    stop("The palaeoverse package is required. Install it with install.packages(\"palaeoverse\")")
  } else{
    library(palaeoverse)
  }
  if(!requireNamespace("deeptime", quietly=TRUE)){
    stop("The deeptime package is required. Install it with install.packages(\"deeptime\")")
  } else{
    library(deeptime)
    data(stages, package="deeptime")
  }

  #bin into stages using palaeoverse functions
  bins <- palaeoverse::time_bins(interval=c(early_stage, late_stage),
                    rank="stage")
  binned_dat <- palaeoverse::bin_time(occdf = dat, bins=bins, method='mid')

  # match to stage using midpoint_stage_lookup()
  binned_dat$stage <- apply(
    binned_dat, 1,
    function(row) {
      midpoint <- as.numeric(row["bin_midpoint"])
      if (is.na(midpoint)) {
        NA
      } else {
        midpoint_stage_lookup(midpoint)
      }
    }
  )

  return(binned_dat)
}


# Add palaeocoordinates - palaeoverse functions
get_palaeocoordinates <- function(dat){

  required_cols <- c("lng", "lat", "bin_midpoint")
  missing_cols <- setdiff(required_cols, names(dat))
  if (length(missing_cols) > 0L) {
    stop(
      sprintf("The input data is missing required columns: %s.",
              paste(missing_cols, collapse = ", ")),
      call. = FALSE
    )
  }

  total_rows <- nrow(dat)
  rows_with_missing_coordinates <- !complete.cases(dat[required_cols])
  blank_data <- sum(rows_with_missing_coordinates)
  lost_percent <- if (total_rows == 0L) 0 else 100 * blank_data / total_rows
  message(sprintf(
    "Lost %d occurrences because lng, lat, or bin_midpoint was missing.",
    blank_data
  ))

  dat <- dat[!rows_with_missing_coordinates,]

  rotated_dat <- palaeoverse::palaeorotate(dat, lng="lng", lat="lat", age="bin_midpoint", model="PALEOMAP", method="point")
  return(rotated_dat)

}

# remove NAs in formation, plat, and plng
get_squeaky_clean <- function(dat, report=TRUE){

  if(report==TRUE){
    report <- as.data.frame(matrix(NA, nrow=2, ncol=1))
    rownames(report) <- c('NA formations', 'NA coordinates')
    report['Lost formations:'] <- nrow(subset(dat, is.na(formation)))
    report['Lost coordinates:'] <- nrow(subset(dat, is.na(p_lat)))
    message(print(report))
  }

  squeaky_clean_dat <- dat[!is.na(dat$formation) & !is.na(dat$p_lat),]
  return(squeaky_clean_dat)

}








