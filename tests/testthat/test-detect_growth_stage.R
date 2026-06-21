test_that("detect_growth_stage renvoie une ligne par parcelle", {
  tab <- smooth_timeseries(ndvi_demo_table())
  stages <- detect_growth_stage(tab)

  expect_s3_class(stages, "data.frame")
  expect_equal(nrow(stages), length(unique(tab$parcel_id)))
  expect_true(all(c("parcel_id", "start_growth_date", "peak_date",
                     "peak_ndvi", "senescence_date") %in% names(stages)))
})

test_that("detect_growth_stage detecte le maximum comme pic", {
  tab <- smooth_timeseries(ndvi_demo_table())
  stages <- detect_growth_stage(tab)

  for (pid in stages$parcel_id) {
    sub <- tab[tab$parcel_id == pid, ]
    expected_peak <- max(sub$smoothed, na.rm = TRUE)
    observed_peak <- stages$peak_ndvi[stages$parcel_id == pid]
    expect_equal(observed_peak, expected_peak, tolerance = 1e-8)
  }
})

test_that("detect_growth_stage leve une erreur si value_col absente", {
  tab <- ndvi_demo_table()
  expect_error(
    detect_growth_stage(tab, value_col = "colonne_inexistante"),
    "absente"
  )
})

test_that("detect_growth_stage utilise 'mean' si 'smoothed' est absent", {
  tab <- ndvi_demo_table()
  expect_false("smoothed" %in% names(tab))
  stages <- detect_growth_stage(tab)
  expect_equal(nrow(stages), length(unique(tab$parcel_id)))
})
