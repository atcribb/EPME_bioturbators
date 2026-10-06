# Build an interactive DAG for the cleaning pipeline.
# Run from the repository root after sourcing the same _targets.R pipeline.

dag <- targets::tar_visnetwork()
htmlwidgets::saveWidget(
  dag,
  file = "outputs/cleaning_pipeline_dag.html",
  selfcontained = TRUE
)
