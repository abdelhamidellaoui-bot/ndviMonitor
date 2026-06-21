#' Lisser une série temporelle NDVI
#'
#' Applique un lissage par moyenne mobile ou par régression locale
#' (LOESS) à une série temporelle de NDVI, parcelle par parcelle, afin de
#' réduire le bruit (nuages résiduels, ombres, bruit capteur).
#'
#' @param ndvi_table `data.frame` issu de [extract_ndvi()], avec au
#'   minimum les colonnes `parcel_id`, `date` et une colonne de valeur
#'   (`value_col`).
#' @param method Méthode de lissage : `"moving_average"` (défaut) ou
#'   `"loess"`.
#' @param value_col Nom de la colonne à lisser. Par défaut `"mean"`.
#' @param window Taille de la fenêtre (nombre de points, impair de
#'   préférence) pour la moyenne mobile. Par défaut `3`.
#' @param span Paramètre `span` du LOESS (0-1, plus la valeur est
#'   grande, plus le lissage est fort). Par défaut `0.5`.
#'
#' @return Le `data.frame` d'entrée complété d'une colonne `smoothed`.
#' @export
#'
#' @examples
#' ndvi_table <- ndvi_demo_table()
#' smooth_timeseries(ndvi_table, method = "moving_average")
smooth_timeseries <- function(ndvi_table,
                               method = c("moving_average", "loess"),
                               value_col = "mean",
                               window = 3,
                               span = 0.5) {
  method <- match.arg(method)

  required <- c("parcel_id", "date", value_col)
  missing_cols <- setdiff(required, names(ndvi_table))
  if (length(missing_cols) > 0) {
    stop(
      "Colonnes manquantes dans 'ndvi_table' : ",
      paste(missing_cols, collapse = ", "), call. = FALSE
    )
  }

  ndvi_table <- ndvi_table[order(ndvi_table$parcel_id, ndvi_table$date), ]
  ndvi_table$smoothed <- NA_real_

  for (pid in unique(ndvi_table$parcel_id)) {
    idx <- which(ndvi_table$parcel_id == pid)
    y <- ndvi_table[[value_col]][idx]
    x <- as.numeric(ndvi_table$date[idx])

    if (length(idx) < 3) {
      ndvi_table$smoothed[idx] <- y
      next
    }

    if (method == "moving_average") {
      w <- max(1, min(window, length(y)))
      smoothed <- stats::filter(y, rep(1 / w, w), sides = 2)
      smoothed <- as.numeric(smoothed)
      na_idx <- is.na(smoothed)
      smoothed[na_idx] <- y[na_idx]
    } else {
      fit <- stats::loess(y ~ x, span = span, na.action = stats::na.exclude)
      smoothed <- as.numeric(stats::predict(fit, newdata = data.frame(x = x)))
    }

    ndvi_table$smoothed[idx] <- smoothed
  }

  ndvi_table
}
