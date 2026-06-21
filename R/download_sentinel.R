#' Télécharger des images Sentinel-2 (bandes Rouge et NIR)
#'
#' Interroge le catalogue STAC public **Microsoft Planetary Computer**
#' pour récupérer les scènes Sentinel-2 Niveau 2A (réflectance de
#' surface) couvrant l'emprise des parcelles agricoles fournies, sur une
#' période donnée, puis télécharge les bandes Rouge (B04) et Proche
#' Infrarouge (B08) nécessaires au calcul du NDVI.
#'
#' Microsoft Planetary Computer est un catalogue STAC public, gratuit et
#' ne nécessitant pas de clé d'API pour la recherche ; un jeton de
#' signature est obtenu automatiquement pour le téléchargement des
#' fichiers via [rstac::sign_planetary_computer()]. Cette fonction
#' nécessite le package \pkg{rstac} (voir `Suggests`) ainsi qu'un accès
#' Internet.
#'
#' @param parcels Objet [sf::sf] représentant l'emprise d'étude (sortie
#'   de [import_parcels()]).
#' @param start_date,end_date Dates de début et de fin
#'   (`"AAAA-MM-JJ"`).
#' @param max_cloud_cover Pourcentage maximal de couverture nuageuse
#'   accepté (0-100). Par défaut `20`.
#' @param dest_dir Dossier où enregistrer les bandes téléchargées. Créé
#'   si nécessaire. Par défaut `"sentinel_data"`.
#' @param collection Nom de la collection STAC. Par défaut
#'   `"sentinel-2-l2a"`.
#' @param max_items Nombre maximal de scènes recherchées. Par défaut
#'   `10`.
#'
#' @return Une liste (invisible) contenant `$items` (objet STAC retourné
#'   par \pkg{rstac}, filtré sur la couverture nuageuse) et `$files`
#'   (chemins des fichiers Rouge / NIR téléchargés localement).
#' @export
#'
#' @examples
#' \dontrun{
#' parcels <- import_parcels("parcelles.geojson", plot = FALSE)
#' sentinel <- download_sentinel(
#'   parcels,
#'   start_date = "2024-03-01", end_date = "2024-07-01",
#'   max_cloud_cover = 20, dest_dir = "sentinel_data"
#' )
#' sentinel$files
#' }
download_sentinel <- function(parcels,
                               start_date,
                               end_date,
                               max_cloud_cover = 20,
                               dest_dir = "sentinel_data",
                               collection = "sentinel-2-l2a",
                               max_items = 10) {
  if (!requireNamespace("rstac", quietly = TRUE)) {
    stop(
      "Le package 'rstac' est requis pour telecharger des images ",
      "Sentinel-2.\nInstallez-le avec install.packages('rstac').",
      call. = FALSE
    )
  }
  if (!inherits(parcels, "sf")) {
    stop("'parcels' doit etre un objet sf (voir import_parcels()).", call. = FALSE)
  }

  dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)

  bbox <- sf::st_bbox(sf::st_transform(parcels, 4326))
  stac_source <- "https://planetarycomputer.microsoft.com/api/stac/v1"

  search <- rstac::stac(stac_source)
  search <- rstac::stac_search(
    search,
    collections = collection,
    bbox        = as.numeric(bbox),
    datetime    = paste(start_date, end_date, sep = "/"),
    limit       = max_items
  )
  search <- rstac::get_request(search)
  search <- rstac::items_sign(search, sign_fn = rstac::sign_planetary_computer())

  n_features <- length(search$features)
  if (n_features == 0) {
    stop(
      "Aucune scene Sentinel-2 trouvee pour cette emprise et cette ",
      "periode.", call. = FALSE
    )
  }

  cloud_values <- vapply(search$features, function(f) {
    val <- f$properties[["eo:cloud_cover"]]
    if (is.null(val)) NA_real_ else as.numeric(val)
  }, numeric(1))

  keep <- which(!is.na(cloud_values) & cloud_values <= max_cloud_cover)
  if (length(keep) == 0) {
    stop(
      "Aucune scene Sentinel-2 ne respecte le seuil de nuages (",
      max_cloud_cover, "%) sur la periode demandee.", call. = FALSE
    )
  }
  search$features <- search$features[keep]

  files <- character(0)
  for (item in search$features) {
    date_tag <- substr(item$properties$datetime, 1, 10)
    for (band in c("B04", "B08")) {
      asset <- item$assets[[band]]
      if (is.null(asset)) next
      out_file <- file.path(dest_dir, sprintf("%s_%s.tif", date_tag, band))
      if (!file.exists(out_file)) {
        utils::download.file(asset$href, out_file, mode = "wb", quiet = TRUE)
      }
      files <- c(files, out_file)
    }
  }

  message(sprintf(
    "%d scene(s) Sentinel-2 telechargee(s) (nuages <= %d%%) dans '%s'.",
    length(search$features), max_cloud_cover, dest_dir
  ))

  invisible(list(items = search, files = files))
}
