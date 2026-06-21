#' Parcelles agricoles de démonstration (plaine du Gharb, Kénitra, Maroc)
#'
#' Un jeu de données synthétique de 4 parcelles agricoles, représentatif
#' de la plaine du Gharb près de Kénitra (Maroc), une région agricole
#' réelle cultivée en céréales, betterave sucrière, maïs et riz. Les
#' géométries sont fictives mais de taille et de localisation réalistes ;
#' elles permettent de tester le package sans dépendre d'un fichier
#' externe.
#'
#' @format Un objet [sf::sf] de 4 entités (polygones) et 3 champs :
#' \describe{
#'   \item{parcel_id}{Identifiant unique de la parcelle (`"P1"`...`"P4"`).}
#'   \item{crop}{Culture pratiquée (`"Ble"`, `"Betterave sucriere"`,
#'     `"Mais"`, `"Riz"`).}
#'   \item{area_ha}{Surface de la parcelle, en hectares.}
#' }
#' @source Données synthétiques générées par
#'   `data-raw/generate_demo_data.R`, à des fins pédagogiques. Pour des
#'   parcelles réelles, voir [import_parcels()].
#' @examples
#' data(demo_parcels)
#' plot(sf::st_geometry(demo_parcels))
"demo_parcels"

#' Empilement NDVI de démonstration (Sentinel-2 simulé)
#'
#' Construit, à partir des bandes Rouge (B04) et Proche Infrarouge (B08)
#' synthétiques fournies avec le package (`inst/extdata/sentinel_demo`),
#' un empilement temporel de NDVI couvrant les 4 parcelles de
#' [demo_parcels], sur 7 dates entre février et juin (saison de
#' croissance). Ces données imitent la structure de produits Sentinel-2
#' L2A réels mais sont entièrement synthétiques, ce qui permet des
#' exemples et tests reproductibles sans connexion Internet.
#'
#' @return Un objet [terra::SpatRaster] à 7 couches, une par date.
#' @export
#'
#' @examples
#' ndvi_stack <- ndvi_demo_stack()
#' ndvi_stack
#' terra::plot(ndvi_stack)
ndvi_demo_stack <- function() {
  dir <- system.file("extdata", "sentinel_demo", package = "ndviMonitor")
  if (!nzchar(dir)) {
    stop("Donnees de demonstration introuvables dans le package.", call. = FALSE)
  }
  red_files <- sort(list.files(dir, pattern = "_B04\\.tif$", full.names = TRUE))
  nir_files <- sort(list.files(dir, pattern = "_B08\\.tif$", full.names = TRUE))
  dates <- sub("_B04\\.tif$", "", basename(red_files))
  calc_ndvi(red_files, nir_files, dates = dates)
}

#' Tableau NDVI de démonstration par parcelle
#'
#' Combine [ndvi_demo_stack()] et [demo_parcels] pour produire directement
#' un tableau NDVI long (date x parcelle), prêt à être utilisé avec
#' [smooth_timeseries()], [detect_growth_stage()] ou [detect_stress()].
#'
#' @return Un `data.frame`, voir [extract_ndvi()].
#' @export
#'
#' @examples
#' head(ndvi_demo_table())
ndvi_demo_table <- function() {
  extract_ndvi(ndvi_demo_stack(), demo_parcels)
}
