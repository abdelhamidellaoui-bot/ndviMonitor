#' Extraire les statistiques NDVI par parcelle
#'
#' Calcule des statistiques zonales (moyenne et/ou médiane) du NDVI pour
#' chaque parcelle agricole et pour chaque date d'un empilement temporel,
#' et renvoie un tableau "long" (une ligne par parcelle x date) prêt pour
#' l'analyse de séries temporelles.
#'
#' @param ndvi_stack Objet [terra::SpatRaster] multi-couches (sortie de
#'   [calc_ndvi()]), une couche par date.
#' @param parcels Objet [sf::sf] des parcelles (sortie de
#'   [import_parcels()]). Doit contenir une colonne `parcel_id`.
#' @param stats Statistiques à calculer parmi `"mean"` et `"median"`.
#'   Par défaut, les deux.
#'
#' @return Un `data.frame` avec les colonnes `parcel_id`, `date`, et
#'   `mean` et/ou `median`.
#' @export
#'
#' @examples
#' ndvi_stack <- ndvi_demo_stack()
#' extract_ndvi(ndvi_stack, demo_parcels)
extract_ndvi <- function(ndvi_stack, parcels, stats = c("mean", "median")) {
  stats <- match.arg(stats, c("mean", "median"), several.ok = TRUE)

  if (!inherits(ndvi_stack, "SpatRaster")) {
    stop("'ndvi_stack' doit etre un objet SpatRaster (voir calc_ndvi()).", call. = FALSE)
  }
  if (!inherits(parcels, "sf")) {
    stop("'parcels' doit etre un objet sf (voir import_parcels()).", call. = FALSE)
  }
  if (!"parcel_id" %in% names(parcels)) {
    stop("'parcels' doit contenir une colonne 'parcel_id'.", call. = FALSE)
  }

  parcels_v <- terra::vect(sf::st_transform(parcels, terra::crs(ndvi_stack)))
  layer_dates <- names(ndvi_stack)

  rows <- lapply(seq_along(layer_dates), function(i) {
    layer <- ndvi_stack[[i]]
    df <- data.frame(parcel_id = parcels$parcel_id, date = layer_dates[i],
                      stringsAsFactors = FALSE)
    if ("mean" %in% stats) {
      df$mean <- terra::extract(layer, parcels_v, fun = mean, na.rm = TRUE,
                                 ID = FALSE)[[1]]
    }
    if ("median" %in% stats) {
      df$median <- terra::extract(layer, parcels_v, fun = stats::median,
                                   na.rm = TRUE, ID = FALSE)[[1]]
    }
    df
  })

  out <- do.call(rbind, rows)
  out$date <- as.Date(out$date)
  out <- out[order(out$parcel_id, out$date), ]
  rownames(out) <- NULL
  out
}
