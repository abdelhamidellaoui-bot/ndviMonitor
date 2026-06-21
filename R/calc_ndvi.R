#' Calculer le NDVI à partir des bandes Rouge et NIR
#'
#' Calcule le Normalized Difference Vegetation Index (NDVI) :
#' \deqn{NDVI = \frac{NIR - Red}{NIR + Red}}
#' pour une ou plusieurs paires d'images Rouge / Proche Infrarouge, et
#' renvoie un empilement (stack) temporel [terra::SpatRaster], une
#' couche par date.
#'
#' @param red_files,nir_files Vecteurs de chemins vers les fichiers
#'   raster (ou objets [terra::SpatRaster] déjà chargés) des bandes
#'   Rouge et NIR, dans le même ordre, une paire par date.
#' @param dates Vecteur de dates (`Date` ou caractère `"AAAA-MM-JJ"`)
#'   associées à chaque paire d'images. Si `NULL`, des étiquettes
#'   factices `"D1"`, `"D2"`, ... sont utilisées.
#' @param clamp Logique. Si `TRUE` (par défaut), les valeurs de NDVI
#'   sont bornées dans `[-1, 1]`.
#'
#' @return Un objet [terra::SpatRaster] multi-couches (une couche par
#'   date), nommé d'après `dates`.
#' @export
#'
#' @examples
#' ndvi_stack <- ndvi_demo_stack()
#' ndvi_stack
calc_ndvi <- function(red_files, nir_files, dates = NULL, clamp = TRUE) {
  if (length(red_files) != length(nir_files)) {
    stop("'red_files' et 'nir_files' doivent avoir la meme longueur.", call. = FALSE)
  }
  n <- length(red_files)
  if (n == 0) {
    stop("'red_files' et 'nir_files' sont vides.", call. = FALSE)
  }

  if (is.null(dates)) {
    dates <- paste0("D", seq_len(n))
  } else {
    dates <- as.character(dates)
  }
  if (length(dates) != n) {
    stop("'dates' doit avoir la meme longueur que 'red_files'.", call. = FALSE)
  }

  layers <- vector("list", n)
  for (i in seq_len(n)) {
    red <- if (inherits(red_files[[i]], "SpatRaster")) {
      red_files[[i]]
    } else {
      terra::rast(red_files[[i]])
    }
    nir <- if (inherits(nir_files[[i]], "SpatRaster")) {
      nir_files[[i]]
    } else {
      terra::rast(nir_files[[i]])
    }

    if (!isTRUE(terra::compareGeom(red, nir, stopOnError = FALSE))) {
      nir <- terra::resample(nir, red)
    }

    ndvi <- (nir - red) / (nir + red)
    if (isTRUE(clamp)) {
      ndvi <- terra::clamp(ndvi, lower = -1, upper = 1, values = TRUE)
    }
    names(ndvi) <- dates[i]
    layers[[i]] <- ndvi
  }

  ndvi_stack <- terra::rast(layers)

  parsed_dates <- tryCatch(as.Date(dates), error = function(e) NULL)
  if (!is.null(parsed_dates) && !anyNA(parsed_dates)) {
    terra::time(ndvi_stack) <- parsed_dates
  }

  ndvi_stack
}
