test_that("extract_ndvi renvoie un data.frame avec les bonnes colonnes", {
  ndvi_stack <- ndvi_demo_stack()
  tab <- extract_ndvi(ndvi_stack, demo_parcels)

  expect_s3_class(tab, "data.frame")
  expect_true(all(c("parcel_id", "date", "mean", "median") %in% names(tab)))
  expect_equal(nrow(tab), nrow(demo_parcels) * terra::nlyr(ndvi_stack))
})

test_that("extract_ndvi respecte le parametre stats", {
  ndvi_stack <- ndvi_demo_stack()
  tab <- extract_ndvi(ndvi_stack, demo_parcels, stats = "mean")

  expect_true("mean" %in% names(tab))
  expect_false("median" %in% names(tab))
})

test_that("extract_ndvi leve une erreur sans colonne parcel_id", {
  ndvi_stack <- ndvi_demo_stack()
  bad_parcels <- demo_parcels
  names(bad_parcels)[names(bad_parcels) == "parcel_id"] <- "id"

  expect_error(extract_ndvi(ndvi_stack, bad_parcels), "parcel_id")
})

test_that("les valeurs NDVI extraites sont bornees dans [-1, 1]", {
  ndvi_stack <- ndvi_demo_stack()
  tab <- extract_ndvi(ndvi_stack, demo_parcels)

  expect_true(all(tab$mean >= -1 & tab$mean <= 1))
})
