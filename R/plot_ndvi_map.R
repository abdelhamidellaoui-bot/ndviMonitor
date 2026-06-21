#' Cartographier le NDVI
#'
#' Affiche une carte du NDVI (raster) pour une date donnée, avec en
#' option la superposition des contours des parcelles agricoles.
#'
#' @param ndvi_stack Objet [terra::SpatRaster] (sortie de
#'   [calc_ndvi()]).
#' @param date Date (ou nom de couche) à afficher. Par défaut, la
#'   dernière date disponible dans `ndvi_stack`.
#' @param parcels Objet [sf::sf] optionnel à superposer en contours.
#' @param title Titre de la carte.
#'
#' @return Invisible (`NULL`). La carte est affichée dans le
#'   périphérique graphique courant.
#' @export
#'
#' @examples
#' ndvi_stack <- ndvi_demo_stack()
#' plot_ndvi_map(ndvi_stack, parcels = demo_parcels)
plot_ndvi_map <- function(ndvi_stack, date = NULL, parcels = NULL,
                           title = "Carte NDVI") {
  if (!inherits(ndvi_stack, "SpatRaster")) {
    stop("'ndvi_stack' doit etre un objet SpatRaster.", call. = FALSE)
  }

  layer_name <- if (is.null(date)) {
    names(ndvi_stack)[terra::nlyr(ndvi_stack)]
  } else {
    as.character(date)
  }
  if (!layer_name %in% names(ndvi_stack)) {
    stop(
      "La date/couche '", layer_name, "' n'existe pas dans 'ndvi_stack'.",
      call. = FALSE
    )
  }

  layer <- ndvi_stack[[layer_name]]

  ndvi_palette <- grDevices::colorRampPalette(
    c("#A52A2A", "#FFD700", "#1B5E20")
  )(100)

  terra::plot(
    layer, col = ndvi_palette, range = c(-1, 1),
    main = paste0(title, " - ", layer_name)
  )

  if (!is.null(parcels)) {
    parcels_v <- terra::vect(sf::st_transform(parcels, terra::crs(ndvi_stack)))
    terra::plot(parcels_v, add = TRUE, border = "black", col = NA, lwd = 1.5)
  }

  invisible(NULL)
}
