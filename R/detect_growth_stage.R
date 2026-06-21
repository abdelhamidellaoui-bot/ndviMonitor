#' Détecter les stades phénologiques simples (croissance, pic, sénescence)
#'
#' Identifie, pour chaque parcelle, trois stades phénologiques simples à
#' partir d'une série temporelle de NDVI (de préférence lissée) : le
#' début de croissance (premier dépassement d'un seuil NDVI), le pic
#' végétatif (valeur maximale) et le début de sénescence (première baisse
#' marquée après le pic).
#'
#' @param ndvi_table `data.frame` issu de [extract_ndvi()] ou
#'   [smooth_timeseries()].
#' @param value_col Colonne de NDVI à utiliser. Par défaut, `"smoothed"`
#'   si elle existe, sinon `"mean"`.
#' @param growth_threshold Seuil de NDVI au-dessus duquel la croissance
#'   est considérée comme commencée. Par défaut `0.3`.
#' @param senescence_drop Baisse relative de NDVI par rapport au pic
#'   (fraction, ex. `0.10` pour -10 %) à partir de laquelle la
#'   sénescence est déclarée. Par défaut `0.10`.
#'
#' @return Un `data.frame` avec une ligne par parcelle et les colonnes
#'   `parcel_id`, `start_growth_date`, `peak_date`, `peak_ndvi`,
#'   `senescence_date`.
#' @export
#'
#' @examples
#' ndvi_table <- ndvi_demo_table()
#' detect_growth_stage(ndvi_table, value_col = "mean")
detect_growth_stage <- function(ndvi_table,
                                 value_col = NULL,
                                 growth_threshold = 0.3,
                                 senescence_drop = 0.10) {
  if (is.null(value_col)) {
    value_col <- if ("smoothed" %in% names(ndvi_table)) "smoothed" else "mean"
  }
  if (!value_col %in% names(ndvi_table)) {
    stop("La colonne '", value_col, "' est absente de 'ndvi_table'.", call. = FALSE)
  }

  ndvi_table <- ndvi_table[order(ndvi_table$parcel_id, ndvi_table$date), ]

  result <- do.call(rbind, lapply(
    split(ndvi_table, ndvi_table$parcel_id),
    function(d) {
      y <- d[[value_col]]
      dt <- d$date

      start_idx <- which(y >= growth_threshold)[1]
      peak_idx <- which.max(y)
      peak_val <- if (length(peak_idx) > 0) y[peak_idx] else NA_real_

      senesc_idx <- NA_integer_
      if (length(peak_idx) > 0 && peak_idx < length(y)) {
        after <- (peak_idx + 1):length(y)
        drop_candidates <- after[y[after] <= peak_val * (1 - senescence_drop)]
        if (length(drop_candidates) > 0) senesc_idx <- drop_candidates[1]
      }

      data.frame(
        parcel_id = unique(d$parcel_id),
        start_growth_date = if (!is.na(start_idx)) dt[start_idx] else as.Date(NA),
        peak_date = if (length(peak_idx) > 0) dt[peak_idx] else as.Date(NA),
        peak_ndvi = peak_val,
        senescence_date = if (!is.na(senesc_idx)) dt[senesc_idx] else as.Date(NA)
      )
    }
  ))

  rownames(result) <- NULL
  result
}
