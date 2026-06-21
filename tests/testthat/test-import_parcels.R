test_that("import_parcels lit un GeoJSON et ajoute parcel_id", {
  path <- system.file("extdata", "demo_parcels.geojson", package = "ndviMonitor")
  parcels <- import_parcels(path, plot = FALSE)

  expect_s3_class(parcels, "sf")
  expect_true("parcel_id" %in% names(parcels))
  expect_equal(nrow(parcels), 4)
  expect_false(is.na(sf::st_crs(parcels)))
})

test_that("import_parcels reprojette si target_crs est fourni", {
  path <- system.file("extdata", "demo_parcels.geojson", package = "ndviMonitor")
  parcels <- import_parcels(path, target_crs = 32629, plot = FALSE)

  expect_equal(sf::st_crs(parcels)$epsg, 32629)
})

test_that("import_parcels echoue sur un fichier inexistant", {
  expect_error(import_parcels("fichier_inexistant.shp"), "introuvable")
})

test_that("import_parcels echoue sur un format non supporte", {
  tmp <- tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)
  expect_error(import_parcels(tmp), "Format non supporte")
})
