# data-raw/generate_demo_data.R
# ---------------------------------------------------------------------------
# Genere les jeux de donnees d'exemple du package ndviMonitor :
#   1. demo_parcels        : 4 parcelles agricoles synthetiques (sf), situees
#                             dans la plaine du Gharb pres de Kenitra (Maroc),
#                             une region agricole reelle (cereales, betterave
#                             sucriere, mais, riz).
#   2. inst/extdata/demo_parcels.geojson : meme objet, au format GeoJSON,
#                             utilise dans les exemples de import_parcels().
#   3. inst/extdata/sentinel_demo/*.tif  : bandes Rouge (B04) et Proche
#                             Infrarouge (B08) synthetiques, 8 dates
#                             (fevrier a juin), imitant la structure et la
#                             resolution des produits Sentinel-2 L2A reels
#                             (reflectance de surface, bandes 10 m).
#
# Ces donnees sont SYNTHETIQUES : elles sont generees a partir de courbes
# NDVI saisonnieres realistes (type double-logistique) propres a chaque
# culture, afin de permettre des exemples, tests et une vignette
# reproductibles SANS connexion Internet. Pour des donnees Sentinel-2
# reelles, utiliser download_sentinel(), qui interroge le catalogue STAC
# public et gratuit Microsoft Planetary Computer.
# ---------------------------------------------------------------------------

library(sf)
library(terra)

set.seed(42)

# ---------------------------------------------------------------------------
# 1. Parcelles agricoles synthetiques (plaine du Gharb, region de Kenitra)
# ---------------------------------------------------------------------------

make_parcel <- function(cx, cy, w, h, id, crop) {
  poly <- st_polygon(list(matrix(
    c(cx - w / 2, cy - h / 2,
      cx + w / 2, cy - h / 2,
      cx + w / 2, cy + h / 2,
      cx - w / 2, cy + h / 2,
      cx - w / 2, cy - h / 2),
    ncol = 2, byrow = TRUE
  )))
  st_sf(parcel_id = id, crop = crop, geometry = st_sfc(poly))
}

# coordonnees approximatives en degres decimaux (WGS84) pres de Kenitra
base_lon <- -6.580
base_lat <- 34.270
deg_per_m <- 1 / 111320  # approximation locale

p1 <- make_parcel(base_lon,                       base_lat,
                   300 * deg_per_m, 200 * deg_per_m, "P1", "Ble")
p2 <- make_parcel(base_lon + 400 * deg_per_m,      base_lat,
                   280 * deg_per_m, 220 * deg_per_m, "P2", "Betterave sucriere")
p3 <- make_parcel(base_lon,                        base_lat + 300 * deg_per_m,
                   320 * deg_per_m, 200 * deg_per_m, "P3", "Mais")
p4 <- make_parcel(base_lon + 400 * deg_per_m,      base_lat + 300 * deg_per_m,
                   280 * deg_per_m, 220 * deg_per_m, "P4", "Riz")

demo_parcels <- rbind(p1, p2, p3, p4)
st_crs(demo_parcels) <- 4326
demo_parcels$area_ha <- round(as.numeric(st_area(
  st_transform(demo_parcels, 32629))) / 10000, 2)
demo_parcels <- demo_parcels[, c("parcel_id", "crop", "area_ha", "geometry")]

dir.create("data", showWarnings = FALSE)
save(demo_parcels, file = "data/demo_parcels.rda", compress = "xz")

dir.create("inst/extdata", showWarnings = FALSE, recursive = TRUE)
st_write(demo_parcels, "inst/extdata/demo_parcels.geojson", delete_dsn = TRUE,
          quiet = TRUE)

# ---------------------------------------------------------------------------
# 2. Bandes Sentinel-2 synthetiques (Rouge B04 / NIR B08), 8 dates
# ---------------------------------------------------------------------------

dates <- seq(as.Date("2024-02-01"), as.Date("2024-06-15"), by = "21 days")

# courbe NDVI saisonniere (double-logistique simplifiee) par culture
seasonal_ndvi <- function(day_of_year, crop) {
  params <- switch(crop,
    "Ble"                = list(base = 0.15, amp = 0.65, peak = 95,  sigma = 35),
    "Betterave sucriere" = list(base = 0.15, amp = 0.55, peak = 120, sigma = 40),
    "Mais"               = list(base = 0.15, amp = 0.70, peak = 150, sigma = 30),
    "Riz"                = list(base = 0.15, amp = 0.60, peak = 160, sigma = 25)
  )
  with(params, base + amp * exp(-((day_of_year - peak)^2) / (2 * sigma^2)))
}

parcels_utm <- st_transform(demo_parcels, 32629)
buffer_ext  <- st_bbox(st_buffer(st_union(parcels_utm), 80))
template <- rast(
  xmin = buffer_ext["xmin"], xmax = buffer_ext["xmax"],
  ymin = buffer_ext["ymin"], ymax = buffer_ext["ymax"],
  resolution = 10, crs = "EPSG:32629"
)

out_dir <- "inst/extdata/sentinel_demo"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

parcels_v <- vect(parcels_utm)

for (d in dates) {
  d <- as.Date(d, origin = "1970-01-01")
  doy <- as.numeric(format(d, "%j"))

  ndvi_r <- template
  values(ndvi_r) <- 0.15 + stats::rnorm(ncell(template), 0, 0.01)  # sol nu / fond

  for (i in seq_len(nrow(demo_parcels))) {
    crop_i <- demo_parcels$crop[i]
    ndvi_val <- seasonal_ndvi(doy, crop_i)
    mask_i <- rasterize(parcels_v[i, ], template)
    tmp <- template
    values(tmp) <- ndvi_val + stats::rnorm(ncell(template), 0, 0.015)
    ndvi_r <- cover(mask(tmp, mask_i), ndvi_r)
  }

  ndvi_r <- clamp(ndvi_r, -1, 1, values = TRUE)

  # inversion NDVI -> Rouge / NIR (somme de reflectance ~ S, bruit capteur)
  S_r <- template
  values(S_r) <- 0.55 + stats::rnorm(ncell(template), 0, 0.01)
  nir_r <- (1 + ndvi_r) * S_r / 2
  red_r <- (1 - ndvi_r) * S_r / 2
  nir_r <- clamp(nir_r, 0.001, 1, values = TRUE)
  red_r <- clamp(red_r, 0.001, 1, values = TRUE)

  date_tag <- format(d, "%Y-%m-%d")
  writeRaster(red_r, file.path(out_dir, paste0(date_tag, "_B04.tif")),
              overwrite = TRUE)
  writeRaster(nir_r, file.path(out_dir, paste0(date_tag, "_B08.tif")),
              overwrite = TRUE)
}

message("Donnees de demonstration generees avec succes.")
