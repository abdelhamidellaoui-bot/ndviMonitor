test_that("detect_stress ajoute les colonnes attendues", {
  tab <- ndvi_demo_table()
  out <- detect_stress(tab)

  expect_true(all(c("historical_mean", "pct_deviation", "alert_type",
                     "alert") %in% names(out)))
  expect_equal(nrow(out), nrow(tab))
})

test_that("detect_stress calcule correctement la moyenne historique", {
  tab <- ndvi_demo_table()
  out <- detect_stress(tab)

  for (pid in unique(tab$parcel_id)) {
    expected <- mean(tab$mean[tab$parcel_id == pid])
    observed <- unique(out$historical_mean[out$parcel_id == pid])
    expect_equal(observed, expected, tolerance = 1e-8)
  }
})

test_that("detect_stress signale 'normal' quand aucune anomalie", {
  flat_tab <- data.frame(
    parcel_id = "P1",
    date = seq(as.Date("2024-01-01"), by = "10 days", length.out = 6),
    mean = rep(0.5, 6)
  )
  out <- detect_stress(flat_tab)
  expect_true(all(out$alert_type == "normal"))
  expect_false(any(out$alert))
})

test_that("detect_stress detecte une baisse brutale", {
  drop_tab <- data.frame(
    parcel_id = "P1",
    date = seq(as.Date("2024-01-01"), by = "10 days", length.out = 5),
    mean = c(0.6, 0.6, 0.6, 0.1, 0.6)
  )
  out <- detect_stress(drop_tab, drop_threshold = 0.2)
  expect_true(out$alert[out$date == as.Date("2024-01-31")])
  expect_equal(out$alert_type[out$date == as.Date("2024-01-31")],
               "baisse_brutale")
})
