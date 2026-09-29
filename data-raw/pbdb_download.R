# Download PBDB data
# MANUSCRIPT DOWNLOAD DATE: 29 September 2026

library(readr)

# Parameters
StartInterval = "Capitanian"
EndInterval = "Norian"
Lithologies = "siliciclastic, carbonate, mixed"
Environments = "marine, carbonate, silicic, marginal, reef, stshallow, stdeep, offshore, slope, basin, marineindet"
Outputs = "strat, lith, env, entname"

output_path = paste("data-raw/", StartInterval,"-",EndInterval, "_pbdb_rawdat_", Sys.Date(), ".csv", sep="")
get_pbdb_data(StartInterval, EndInterval, Lithologies, Environments, Outputs,
              output_file = output_path)

#Note that this will need to be manually opened, re-saved without metadata, and then reloaded to generate the .RData file
#For instance -
data_path = "data-raw/Capitanian-Norian_pbdb_rawdatnometa_2026-09-29.csv"
pbdb_dat <- readr::read_csv(
  data_path,
  name_repair = "minimal",
  show_col_types = FALSE
)

colnames(pbdb_dat)






