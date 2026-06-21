#' @noRd
# Evite les fausses notes "no visible binding for global variable" lors de
# R CMD check : 'demo_parcels' est un jeu de donnees charge paresseusement
# (LazyData), reference directement dans ndvi_demo_table().
utils::globalVariables("demo_parcels")
