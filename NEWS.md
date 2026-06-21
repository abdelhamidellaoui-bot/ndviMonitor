# ndviMonitor 0.1.0

* Version initiale du package.
* Fonctions principales : `import_parcels()`, `download_sentinel()`,
  `calc_ndvi()`, `extract_ndvi()`, `smooth_timeseries()`,
  `detect_growth_stage()`, `detect_stress()`, `plot_ndvi_curve()`,
  `plot_ndvi_map()`, `generate_report()`.
* Jeu de données de démonstration `demo_parcels` (4 parcelles, plaine
  du Gharb, Kénitra) et bandes Sentinel-2 synthétiques
  (`inst/extdata/sentinel_demo`) pour des exemples et tests
  reproductibles hors connexion.
* Vignette `ndviMonitor-intro` présentant le flux de travail complet.
* Suite de tests unitaires `testthat` (58 tests).
