test_that("smooth_timeseries ajoute une colonne smoothed", {
  tab <- ndvi_demo_table()
  smoothed <- smooth_timeseries(tab, method = "moving_average")

  expect_true("smoothed" %in% names(smoothed))
  expect_equal(nrow(smoothed), nrow(tab))
  expect_false(any(is.na(smoothed$smoothed)))
})

test_that("smooth_timeseries fonctionne avec la methode loess", {
  tab <- ndvi_demo_table()
  smoothed <- smooth_timeseries(tab, method = "loess", span = 0.6)

  expect_true("smoothed" %in% names(smoothed))
  expect_false(any(is.na(smoothed$smoothed)))
})

test_that("smooth_timeseries leve une erreur si une colonne manque", {
  tab <- ndvi_demo_table()
  tab$mean <- NULL

  expect_error(smooth_timeseries(tab), "Colonnes manquantes")
})

test_that("smooth_timeseries respecte l'ordre parcelle/date", {
  tab <- ndvi_demo_table()
  smoothed <- smooth_timeseries(tab)

  expect_true(all(diff(as.numeric(smoothed$date[smoothed$parcel_id == "P1"])) > 0))
})
