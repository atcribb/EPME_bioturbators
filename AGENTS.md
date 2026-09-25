# Repository Guidelines

## Project Structure & Module Organization

This repository is currently a minimal RStudio project. `EPME_bioturbators.Rproj` defines the project settings, `README.md` is the short project entry point which describes the repository structure and gives the user instructions for use, and `LICENSE` contains the project license. No source, data, or test directories exist yet. As the analysis grows, keep a predictable layout:

- `R/` for reusable functions and analysis modules (`snake_case.R`)
- `scripts/` for runnable analysis scripts 
- `scripts/data_processing` for any scripts that clean and process data-raw into data
- `scripts/simulation` for biogeochemical reactive-transport model simulations
- `scripts/figures` for scripts that produce manuscript figures
- `data-raw/` for sourced inputs such as PBDB data or data from literature 
- `data/` for cleaned and processed derived data to be used in analyses 
- `tests/testthat/` for automated tests
- `figures/` or `outputs/` for generated results, when appropriate

Keep paths project-relative and run work from the RStudio project root.

## Agent description and behavior

The agent is to act as a PhD-level expert in sediment biogeochemistry, bioturbation, and reactive-transport models. The agent is also fluent in R and makes well-documented code that is concise as possible. The agent will keep a running time-stamped document on work progress, including any and all changes it has made to the repository, and what it is learning about the project. The agent will not change files without permission first. The agent with NEVER act or search outside of the EPME_bioturbators repository. The agent can make commits to the repository but it does not have permission to approve pull requests. 


## Build, Test, and Development Commands

There is no build system or test runner configured yet. Open `EPME_bioturbators.Rproj` in RStudio, or start an R session from the repository root. For future R package-style code, use:

```r
source("scripts/run_analysis.R")
testthat::test_dir("tests/testthat")
```

If a reproducible dependency workflow is added, commit its configuration (for example, `renv.lock`) and document the restore command in `README.md`.

## Coding Style & Naming Conventions

Use two-space indentation and UTF-8 text, matching the RStudio project settings. Prefer `snake_case` for files, functions, and variables; use descriptive names rather than abbreviations. Keep reusable logic in `R/`, avoid hidden global state, and add concise comments where analytical choices are non-obvious. Format and lint with `styler` and `lintr` when those dependencies are introduced.

## Testing Guidelines

No tests or coverage threshold are currently configured. New reusable functions should receive `testthat` tests under `tests/testthat/`, named `test-<topic>.R`; run them with `testthat::test_dir("tests/testthat")`. Add tests for data validation, edge cases, and reproducibility-sensitive transformations.

## Commit & Pull Request Guidelines

The existing history contains only `Initial commit`, so no established commit convention is visible. Use short, imperative subjects (for example, `Add sediment summary analysis`) and keep unrelated changes separate. Pull requests should explain the analytical or structural change, list validation commands run, link relevant issues, and include representative figures or screenshots when outputs change.

## Security & Configuration Tips

Do not commit credentials, private data, `.Rhistory`, `.RData`, or `.Rproj.user` contents. Record required packages, input assumptions, and any non-public data setup steps in project documentation.
