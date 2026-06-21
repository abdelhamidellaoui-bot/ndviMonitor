#' Importer des parcelles agricoles
#'
#' Lit un fichier vectoriel de parcelles agricoles (shapefile `.shp` ou
#' GeoJSON `.geojson` / `.json`), vérifie que son système de coordonnées
#' (CRS) est défini, ajoute un identifiant de parcelle si nécessaire et
#' affiche un aperçu graphique.
#'
#' @param path Chemin vers le fichier vectoriel (`.shp`, `.geojson`,
#'   `.json`).
#' @param id_col Nom de la colonne identifiant chaque parcelle. Si la
#'   colonne n'existe pas, un identifiant `parcel_id` est généré
#'   automatiquement (`"P1"`, `"P2"`, ...).
#' @param target_crs Code EPSG (entier) vers lequel reprojeter les
#'   parcelles. Si `NULL` (par défaut), le CRS d'origine est conservé.
#' @param plot Logique. Si `TRUE` (par défaut), un aperçu des parcelles
#'   est affiché dans le périphérique graphique courant.
#'
#' @return Un objet [sf::sf] contenant les parcelles, avec une colonne
#'   `parcel_id`.
#' @export
#'
#' @examples
#' parcels_path <- system.file("extdata", "demo_parcels.geojson",
#'                              package = "ndviMonitor")
#' parcels <- import_parcels(parcels_path, plot = FALSE)
#' parcels
import_parcels <- function(path,
                            id_col = "parcel_id",
                            target_crs = NULL,
                            plot = TRUE) {
  if (!file.exists(path)) {
    stop("Le fichier '", path, "' est introuvable.", call. = FALSE)
  }
  ext <- tolower(tools::file_ext(path))
  if (!ext %in% c("shp", "geojson", "json")) {
    stop(
      "Format non supporte : '.", ext, "'. Utilisez un shapefile (.shp) ",
      "ou un GeoJSON (.geojson/.json).", call. = FALSE
    )
  }

  parcels <- sf::st_read(path, quiet = TRUE)

  if (is.na(sf::st_crs(parcels))) {
    stop(
      "Le fichier importe n'a pas de systeme de coordonnees (CRS) defini.",
      call. = FALSE
    )
  }

  if (!is.null(target_crs)) {
    parcels <- sf::st_transform(parcels, target_crs)
  }

  if (!id_col %in% names(parcels)) {
    parcels[[id_col]] <- paste0("P", seq_len(nrow(parcels)))
  }
  names(parcels)[names(parcels) == id_col] <- "parcel_id"

  parcels <- sf::st_make_valid(parcels)

  message(sprintf(
    "%d parcelle(s) importee(s) | CRS : %s",
    nrow(parcels), sf::st_crs(parcels)$input
  ))

  if (isTRUE(plot)) {
    plot(
      sf::st_geometry(parcels),
      col = "#A8D5BA", border = "#2E7D32",
      main = "Parcelles agricoles importees"
    )
  }

  parcels
}
