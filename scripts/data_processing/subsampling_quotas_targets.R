#Sensitivity test for relationship between cell size threshold and returned subsampling data size. Goal is to maximize returned data size.

subsampling_quotas_targets <- list(
  tar_target(
    subsampling_cell_thresholds,
    seq_len(200)
    ),
  tar_target(
    subsampling_data_return,
    {
      data_return <- as.data.frame(matrix(
        NA,
        nrow = length(subsampling_cell_thresholds),
        ncol = 2
      ))
      colnames(data_return) <- c('cell_threshold', 'data_return_size')
      data_return$cell_threshold <- subsampling_cell_thresholds
      for (i in seq_along(data_return$cell_threshold)){
        data_return$data_return_size[i] <- nrow(
          subsample_space(pt_data, 275, data_return$cell_threshold[i])
        )
      }
      data_return
    }
  ),
  tar_target(
    subsampling_quotas_plot,
    {
      ggplot2::ggplot(subsampling_data_return) +
        ggplot2::geom_point(
          ggplot2::aes(x=cell_threshold, y=data_return_size),
          shape=21,
          fill='grey40'
        ) +
        ggplot2::scale_x_continuous('threshold of occurrences in cells') +
        ggplot2::scale_y_continuous('n subsampled occurrences returend') +
        ggplot2::theme_bw()
    }
  )
)

