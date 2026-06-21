test_that("calc_ndvi calcule des valeurs correctes et bornees", {
  red <- terra::rast(nrows = 5, ncols = 5, vals = rep(0.2, 25))
  nir <- terra::rast(nrows = 5, ncols = 5, vals = rep(0.6, 25))

  ndvi <- calc_ndvi(list(red), list(nir), dates = "2024-01-01")

  expect_s4_class(ndvi, "SpatRaster")
  expect_equal(terra::nlyr(ndvi), 1)
  expected_val <- (0.6 - 0.2) / (0.6 + 0.2)
  expect_equal(unname(terra::global(ndvi, "mean", na.rm = TRUE)[1, 1]),
               expected_val, tolerance = 1e-8)
})

test_that("calc_ndvi empile plusieurs dates dans l'ordre fourni", {
  red <- terra::rast(nrows = 3, ncols = 3, vals = rep(0.2, 9))
  nir <- terra::rast(nrows = 3, ncols = 3, vals = rep(0.4, 9))

  ndvi_stack <- calc_ndvi(
    list(red, red), list(nir, nir),
    dates = c("2024-01-01", "2024-02-01")
  )

  expect_equal(terra::nlyr(ndvi_stack), 2)
  expect_equal(names(ndvi_stack), c("2024-01-01", "2024-02-01"))
})

test_that("calc_ndvi borne les valeurs dans [-1, 1] si clamp = TRUE", {
  red <- terra::rast(nrows = 2, ncols = 2, vals = c(0, 0, 0, 0))
  nir <- terra::rast(nrows = 2, ncols = 2, vals = c(1, 1, 1, 1))

  ndvi <- calc_ndvi(list(red), list(nir), clamp = TRUE)
  vals <- terra::values(ndvi)

  expect_true(all(vals >= -1 & vals <= 1, na.rm = TRUE))
})

test_that("calc_ndvi leve une erreur si les longueurs different", {
  red <- terra::rast(nrows = 2, ncols = 2, vals = rep(0.2, 4))
  nir <- terra::rast(nrows = 2, ncols = 2, vals = rep(0.4, 4))

  expect_error(
    calc_ndvi(list(red, red), list(nir)),
    "meme longueur"
  )
})

test_that("ndvi_demo_stack fonctionne et a 7 couches", {
  ndvi_stack <- ndvi_demo_stack()
  expect_s4_class(ndvi_stack, "SpatRaster")
  expect_equal(terra::nlyr(ndvi_stack), 7)
})
