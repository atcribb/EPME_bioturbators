#Function to subsample time

count_collections <- function(dat){

  stage_list <- unique(dat$stage)

  collection_distribution <- as.data.frame(matrix(NA, nrow=length(stage_list), ncol=1))
  colnames(collection_distribution) <- 'n_collections'
  rownames(collection_distribution) <- stage_list

  for(this_stage in stage_list){
    this_stage_data <- subset(dat, stage==this_stage)
    collection_distribution[this_stage,'n_collections'] <- length(unique(this_stage_data$collection_no))
  }

  return(collection_distribution)

}


subsample_time <- function(dat, colls_quota){

  #Defense!
  if(!("stage" %in% names(pt_data))){
    stop("stages not found in input data.")
  }

  #get collections per stage and report error of colls_quota is greater than any stage
  collection_distribution <- count_collections(dat)
  if(any(colls_quota > collection_distribution$n_collections)){
    stop("Collections quota surpasses number of collections in one of the stages. Check with count_collections() and select a valid quota.")
  }

  #create output -- empty 0 row dataframe to rbind onto
  subsampled_dat <- as.data.frame(matrix(nrow=0, ncol=ncol(dat)))
  colnames(subsampled_dat) <- colnames(dat)

  stage_list <- unique(dat$stage)
  for(this_stage in stage_list){

    this_stage_data <- subset(dat, stage==this_stage)
    this_stage_collections <- unique(this_stage_data$collection_no)
    sampled_collections <- sample(this_stage_collections, colls_quota, replace=FALSE)

    subsampled_stage <- subset(this_stage_data, collection_no %in% sampled_collections)
    subsampled_dat <- rbind(subsampled_dat, subsampled_stage)

  }

  return(timesubsampled_dat)

}

make_cells <- function(dat, cell_size, mapping=FALSE){


  return(dat)

}


subsample_space <- function(dat, cell_size, grid_quota){

  if(!requireNamespace("palaeoverse", quietly=TRUE)){
    stop("The palaeoverse package is required. Install it with install.packages(\"palaeoverse\")")
  } else{
    library(palaeoverse)
  }

  #Break up data into equal earth hexagon grid cells
  dat_gridded <- palaeoverse::bin_space(dat, spacing = cell_size)
  dat_gridded$cell_size <- cell_size

  #select only cells above the grid_quota threshold
  cell_counts <- table(dat_gridded$cell_ID)
  keep_cells <- names(cell_counts)[cell_counts >= grid_quota*1.25]
  threshold_dat <- subset(dat_gridded, cell_ID %in% keep_cells)

  #within those cells, normalise the number of samples
  #set up output with 0 rows and colnames of dat to rbind subsampled grid data
  spacesubsample_dat <- as.data.frame(matrix(NA, nrow=0, ncol=ncol(dat)))
  colnames(spacesubsample_dat) <- colnames(dat)
  cells_list <- unique(threshold_dat$cell_ID)

  for(gridcell in cells_list){

    cell_data <- subset(threshold_dat, cell_ID == gridcell)
    randidxs <- sample(1:nrow(cell_data), grid_quota, replace=FALSE)
    subbed_cell <- cell_data[randidxs,]
    spacesubsample_dat <- rbind(spacesubsample_dat, subbed_cell)

  }

  return(spacesubsample_dat)

}


