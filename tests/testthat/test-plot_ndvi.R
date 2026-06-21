test_that("plot_ndvi_curve renvoie un objet ggplot", {
  tab <- smooth_timeseries(ndvi_demo_table())
  p <- plot_ndvi_curve(tab)

  expect_s3_class(p, "ggplot")
})

test_that("plot_ndvi_curve filtre correctement avec parcels_subset", {
  tab <- smooth_timeseries(ndvi_demo_table())
  p <- plot_ndvi_curve(tab, parcels_subset = c("P1", "P2"))

  expect_s3_class(p, "ggplot")
  expect_true(all(p$data$parcel_id %in% c("P1", "P2")))
})

test_that("plot_ndvi_curve accepte un data.frame de stades", {
  tab <- smooth_timeseries(ndvi_demo_table())
  stages <- detect_growth_stage(tab)
  p <- plot_ndvi_curve(tab, stages = stages)

  expect_s3_class(p, "ggplot")
})

test_that("plot_ndvi_map s'execute sans erreur", {
  ndvi_stack <- ndvi_demo_stack()
  tmp <- tempfile(fileext = ".png")
  grDevices::png(tmp, width = 400, height = 400)
  expect_no_error(plot_ndvi_map(ndvi_stack, parcels = demo_parcels))
  grDevices::dev.off()
  expect_true(file.exists(tmp))
})

test_that("plot_ndvi_map leve une erreur pour une date inexistante", {
  ndvi_stack <- ndvi_demo_stack()
  expect_error(
    plot_ndvi_map(ndvi_stack, date = "1999-01-01"),
    "n'existe pas"
  )
})
