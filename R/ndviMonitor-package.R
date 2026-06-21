#' ndviMonitor : Suivi phénologique des cultures par séries temporelles NDVI
#'
#' `ndviMonitor` propose un flux de travail simple et reproductible pour
#' suivre la phénologie des cultures à partir d'images Sentinel-2 :
#' import de parcelles agricoles, téléchargement d'images Sentinel-2,
#' calcul du NDVI, extraction de statistiques zonales par parcelle,
#' lissage des séries temporelles, détection de stades phénologiques
#' simples et d'anomalies de stress, visualisations et rapport HTML
#' automatique.
#'
#' @section Fonctions principales:
#' \describe{
#'   \item{[import_parcels()]}{Importer des parcelles (shapefile/GeoJSON).}
#'   \item{[download_sentinel()]}{Télécharger des images Sentinel-2
#'     (Microsoft Planetary Computer).}
#'   \item{[calc_ndvi()]}{Calculer le NDVI à partir des bandes Rouge/NIR.}
#'   \item{[extract_ndvi()]}{Extraire les statistiques NDVI par parcelle.}
#'   \item{[smooth_timeseries()]}{Lisser les séries temporelles NDVI.}
#'   \item{[detect_growth_stage()]}{Détecter les stades phénologiques.}
#'   \item{[detect_stress()]}{Détecter des anomalies de stress.}
#'   \item{[plot_ndvi_curve()]}{Tracer les courbes NDVI.}
#'   \item{[plot_ndvi_map()]}{Cartographier le NDVI.}
#'   \item{[generate_report()]}{Générer un rapport HTML automatique.}
#' }
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
## usethis namespace: end
NULL
