# EPME_bioturbators

Tools for analysing sediment bioturbation and its effects on marine
biogeochemical processes given the trace fossil record.

## Reproducible workflow

Install the workflow dependency once:

```r
install.packages(c("targets", "visNetwork", "htmlwidgets", "divDyn"))
```

From the project root, inspect and run the pipeline with:

```r
targets::tar_manifest()
targets::tar_make()
targets::tar_read(package_metadata)
```

The PBDB cleaning steps are declared in `scripts/data_processing/clean_targets.R`
and are included by `_targets.R`. The pipeline reads the metadata-free CSV in
`data-raw/`, trims to the standard long column set, applies taxonomic and
environmental filters as parallel branches, and assigns paleoenvironments on
each branch.

To create an interactive DAG, run from the project root:

```r
source("scripts/data_processing/visualize_clean_targets.R")
```

This calls `tar_visnetwork()` and saves `outputs/cleaning_pipeline_dag.html`.
Generated pipeline state is stored under `_targets/` and is not committed to
Git.

The spatial subsampling quota analysis is defined in
`scripts/data_processing/subsampling_quotas_targets.R`. It grids `pt_data` once
at 275 km spacing, evaluates quotas from 1 to 100, and tracks the returned row
counts and plot as targets. Read the results with:

```r
targets::tar_read(subsampling_data_return)
targets::tar_read(subsampling_quotas_plot)
```

The plot is written to `outputs/subsampling_quotas.png`.

Run the package tests with:

```r
devtools::test()
```
