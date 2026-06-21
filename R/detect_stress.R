#' Détecter des anomalies / stress simples de végétation
#'
#' Compare, pour chaque date et chaque parcelle, le NDVI observé à la
#' moyenne historique de la parcelle (toutes dates confondues) et
#' déclenche une alerte lorsque la baisse dépasse un seuil relatif, ou
#' lorsque la pente du NDVI entre deux dates consécutives est anormalement
#' faible (faible croissance).
#'
#' @param ndvi_table `data.frame` issu de [extract_ndvi()] ou
#'   [smooth_timeseries()].
#' @param value_col Colonne de NDVI à utiliser. Par défaut, `"smoothed"`
#'   si elle existe, sinon `"mean"`.
#' @param drop_threshold Baisse relative par rapport à la moyenne
#'   historique de la parcelle (fraction) à partir de laquelle une
#'   alerte `"baisse_brutale"` est déclenchée. Par défaut `0.20`
#'   (-20 %).
#' @param low_growth_threshold Pente NDVI minimale (différence entre
#'   deux dates consécutives) en-dessous de laquelle une alerte
#'   `"faible_croissance"` est déclenchée. Par défaut `-0.02`.
#'
#' @return Le `data.frame` d'entrée complété des colonnes
#'   `historical_mean`, `pct_deviation`, `alert_type`
#'   (`"baisse_brutale"`, `"faible_croissance"` ou `"normal"`) et
#'   `alert` (logique).
#' @export
#'
#' @examples
#' ndvi_table <- ndvi_demo_table()
#' detect_stress(ndvi_table, value_col = "mean")
detect_stress <- function(ndvi_table,
                           value_col = NULL,
                           drop_threshold = 0.20,
                           low_growth_threshold = -0.02) {
  if (is.null(value_col)) {
    value_col <- if ("smoothed" %in% names(ndvi_table)) "smoothed" else "mean"
  }
  if (!value_col %in% names(ndvi_table)) {
    stop("La colonne '", value_col, "' est absente de 'ndvi_table'.", call. = FALSE)
  }

  ndvi_table <- ndvi_table[order(ndvi_table$parcel_id, ndvi_table$date), ]

  out <- do.call(rbind, lapply(
    split(ndvi_table, ndvi_table$parcel_id),
    function(d) {
      y <- d[[value_col]]
      hist_mean <- mean(y, na.rm = TRUE)
      pct_dev <- (y - hist_mean) / hist_mean
      slope <- c(NA, diff(y))

      alert_type <- ifelse(
        pct_dev <= -drop_threshold, "baisse_brutale",
        ifelse(!is.na(slope) & slope <= low_growth_threshold,
               "faible_croissance", "normal")
      )

      d$historical_mean <- hist_mean
      d$pct_deviation <- pct_dev
      d$alert_type <- alert_type
      d$alert <- alert_type != "normal"
      d
    }
  ))

  rownames(out) <- NULL
  out
}
