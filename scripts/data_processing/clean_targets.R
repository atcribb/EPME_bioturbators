# Targets for cleaning the PBDB occurrence data.
# This file is sourced by the repository-root _targets.R file.

cleaning_targets <- list(
tar_target(
  pbdb_raw_file, "data-raw/Capitanian-Norian_pbdb_rawdatnometa_2026-09-29.csv", format = "file"
  ),
tar_target(
  pbdb_raw, utils::read.csv(pbdb_raw_file, check.names = FALSE, stringsAsFactors = FALSE)
),
tar_target(
  ptdat_trimmed, trim_columns(pbdb_raw, Standard_Long = TRUE)
),
tar_target(
  ptdat_taxclean, taxonomic_clean(ptdat_trimmed)
),
tar_target(
  ptdat_envclean, environment_clean(ptdat_taxclean)
),
tar_target(
  ptdat_palenvs, assign_paleoenvironments(ptdat_envclean)
),
tar_target(
  pt_binned, bin_stages(ptdat_palenvs, "Asselian", "Toarcian")
),
tar_target(
  pt_stageselection, subset(pt_binned, stage %in% c('Capitanian', 'Wuchiapingian', 'Induan', 'Olenekian', 'Anisian', 'Ladinian', 'Carnian'))
),
tar_target(
  pt_rotated, get_palaeocoordinates(pt_stageselection)
),
tar_target(
  pt_data, get_squeaky_clean(pt_rotated)
)
)
