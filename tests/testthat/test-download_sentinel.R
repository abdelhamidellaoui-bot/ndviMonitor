test_that("download_sentinel verifie que 'parcels' est un objet sf", {
  skip_if_not_installed("rstac")
  expect_error(
    download_sentinel(data.frame(x = 1), "2024-01-01", "2024-02-01"),
    "objet sf"
  )
})

test_that("download_sentinel reclame le package rstac si absent", {
  skip_if(requireNamespace("rstac", quietly = TRUE),
          "rstac est installe : ce test ne s'applique pas")
  expect_error(
    download_sentinel(demo_parcels, "2024-01-01", "2024-02-01"),
    "rstac"
  )
})
