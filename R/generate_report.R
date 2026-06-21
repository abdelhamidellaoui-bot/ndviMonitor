#' Générer un rapport automatique HTML
#'
#' Compile un rapport HTML (R Markdown) résumant l'analyse NDVI d'un
#' ensemble de parcelles : statistiques générales, courbes temporelles,
#' carte du dernier NDVI disponible, stades phénologiques détectés et
#' alertes de stress.
#'
#' @param ndvi_table `data.frame` issu de [extract_ndvi()],
#'   [smooth_timeseries()] et/ou [detect_stress()].
#' @param stages `data.frame` issu de [detect_growth_stage()].
#' @param ndvi_stack Objet [terra::SpatRaster] optionnel, pour inclure
#'   une carte NDVI dans le rapport.
#' @param parcels Objet [sf::sf] optionnel, superposé à la carte.
#' @param output_file Chemin du fichier de sortie (`.html`). Par défaut
#'   `"ndvi_report.html"` dans le répertoire courant.
#' @param title Titre du rapport.
#'
#' @return Le chemin (caractère) du rapport généré, de manière
#'   invisible.
#' @export
#'
#' @examples
#' \dontrun{
#' ndvi_table <- smooth_timeseries(ndvi_demo_table())
#' stages <- detect_growth_stage(ndvi_table)
#' generate_report(ndvi_table, stages, output_file = tempfile(fileext = ".html"))
#' }
generate_report <- function(ndvi_table,
                             stages,
                             ndvi_stack = NULL,
                             parcels = NULL,
                             output_file = "ndvi_report.html",
                             title = "Rapport de suivi NDVI") {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Le package 'rmarkdown' est requis pour generer le rapport.", call. = FALSE)
  }

  template <- system.file("rmd", "report_template.Rmd", package = "ndviMonitor")
  if (!nzchar(template)) {
    stop("Le gabarit de rapport est introuvable dans le package.", call. = FALSE)
  }

  out_dir <- dirname(normalizePath(output_file, mustWork = FALSE))
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

  rmarkdown::render(
    input = template,
    output_file = basename(output_file),
    output_dir = out_dir,
    params = list(
      ndvi_table = ndvi_table,
      stages = stages,
      ndvi_stack = ndvi_stack,
      parcels = parcels,
      report_title = title
    ),
    envir = new.env(),
    quiet = TRUE
  )

  result_path <- file.path(out_dir, basename(output_file))
  message("Rapport genere : ", result_path)
  invisible(result_path)
}
