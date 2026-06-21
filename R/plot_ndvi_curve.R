#' Tracer les courbes d'évolution du NDVI
#'
#' Trace l'évolution temporelle du NDVI pour une ou plusieurs parcelles,
#' avec en option l'affichage de la courbe lissée et des dates de pic
#' végétatif détectées.
#'
#' @param ndvi_table `data.frame` issu de [extract_ndvi()] ou
#'   [smooth_timeseries()].
#' @param value_col Colonne de NDVI brute à tracer (points). Par défaut
#'   `"mean"`.
#' @param smoothed_col Colonne de NDVI lissée à superposer (ligne), si
#'   présente dans `ndvi_table`. Par défaut `"smoothed"`. Utiliser
#'   `NULL` pour ne pas l'afficher.
#' @param stages `data.frame` optionnel issu de
#'   [detect_growth_stage()], pour superposer les dates de pic
#'   végétatif.
#' @param parcels_subset Vecteur optionnel d'identifiants de parcelles à
#'   afficher. Par défaut, toutes les parcelles sont affichées.
#' @param title Titre du graphique.
#'
#' @return Un objet `ggplot` (affiché et renvoyé de manière invisible).
#' @export
#'
#' @examples
#' ndvi_table <- smooth_timeseries(ndvi_demo_table())
#' plot_ndvi_curve(ndvi_table)
plot_ndvi_curve <- function(ndvi_table,
                             value_col = "mean",
                             smoothed_col = "smoothed",
                             stages = NULL,
                             parcels_subset = NULL,
                             title = "Evolution temporelle du NDVI") {
  if (!is.null(parcels_subset)) {
    ndvi_table <- ndvi_table[ndvi_table$parcel_id %in% parcels_subset, ]
  }

  p <- ggplot2::ggplot(
    ndvi_table,
    ggplot2::aes(x = .data$date, y = .data[[value_col]], color = .data$parcel_id)
  ) +
    ggplot2::geom_point(alpha = 0.45, size = 1.8) +
    ggplot2::geom_line(alpha = 0.3)

  if (!is.null(smoothed_col) && smoothed_col %in% names(ndvi_table)) {
    p <- p + ggplot2::geom_line(
      ggplot2::aes(y = .data[[smoothed_col]]), linewidth = 1
    )
  }

  if (!is.null(stages)) {
    if (!is.null(parcels_subset)) {
      stages <- stages[stages$parcel_id %in% parcels_subset, ]
    }
    p <- p + ggplot2::geom_point(
      data = stages,
      ggplot2::aes(x = .data$peak_date, y = .data$peak_ndvi),
      inherit.aes = FALSE, shape = 8, size = 3, color = "black"
    )
  }

  p +
    ggplot2::labs(x = "Date", y = "NDVI", color = "Parcelle", title = title) +
    ggplot2::theme_minimal(base_size = 12)
}
