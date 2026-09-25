# EPME_bioturbators

Tools for analysing sediment bioturbation and its effects on marine
biogeochemical processes given the trace fossil record.

## Reproducible workflow

Install the workflow dependency once:

```r
install.packages("targets")
```

From the project root, inspect and run the pipeline with:

```r
targets::tar_manifest()
targets::tar_make()
targets::tar_read(package_metadata)
```

The pipeline definition is in `_targets.R`. Generated pipeline state is stored
under `_targets/` and is not committed to Git.

Run the package tests with:

```r
devtools::test()
```
