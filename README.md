
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ndviMonitor

<!-- badges: start -->

[![R-CMD-check](https://github.com/votre-utilisateur/ndviMonitor/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/votre-utilisateur/ndviMonitor/actions/workflows/R-CMD-check.yaml)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**ndviMonitor** est un package R pour le **suivi phénologique des
cultures** à partir de séries temporelles **NDVI** dérivées d’images
**Sentinel-2**. Il fournit un flux de travail complet et reproductible :
import de parcelles agricoles, téléchargement d’images Sentinel-2,
calcul du NDVI, extraction par parcelle, lissage, détection de stades
phénologiques et d’anomalies de stress, visualisations et rapport HTML
automatique.

## Installation

Vous pouvez installer la version de développement de `ndviMonitor`
depuis [GitHub](https://github.com/) avec :

``` r
# install.packages("remotes")
remotes::install_github("votre-utilisateur/ndviMonitor")
```

## Fonctions principales

| Fonction                | Rôle                                                             |
|-------------------------|------------------------------------------------------------------|
| `import_parcels()`      | Importer des parcelles agricoles (shapefile / GeoJSON)           |
| `download_sentinel()`   | Télécharger des images Sentinel-2 (Microsoft Planetary Computer) |
| `calc_ndvi()`           | Calculer le NDVI à partir des bandes Rouge / NIR                 |
| `extract_ndvi()`        | Extraire les statistiques NDVI par parcelle                      |
| `smooth_timeseries()`   | Lisser les séries temporelles NDVI                               |
| `detect_growth_stage()` | Détecter les stades phénologiques (croissance, pic, sénescence)  |
| `detect_stress()`       | Détecter des anomalies / stress de végétation                    |
| `plot_ndvi_curve()`     | Tracer les courbes d’évolution du NDVI                           |
| `plot_ndvi_map()`       | Cartographier le NDVI                                            |
| `generate_report()`     | Générer un rapport HTML automatique                              |

## Exemple rapide

Le package est livré avec un **jeu de données de démonstration**
(parcelles et bandes Sentinel-2 synthétiques) qui permet de tester
l’ensemble du flux de travail sans connexion Internet.

``` r
library(ndviMonitor)

# 1. Parcelles agricoles de demonstration (plaine du Gharb, Kenitra)
data(demo_parcels)
demo_parcels
#>   parcel_id               crop area_ha
#> 1        P1                Ble    4.95
#> 2        P2 Betterave sucriere    5.08
#> 3        P3               Mais    5.28
#> 4        P4                Riz    5.08
#>                                                                                                       geometry
#> 1 -6.581347, -6.578653, -6.578653, -6.581347, -6.581347, 34.269102, 34.269102, 34.270898, 34.270898, 34.269102
#> 2 -6.577664, -6.575149, -6.575149, -6.577664, -6.577664, 34.269012, 34.269012, 34.270988, 34.270988, 34.269012
#> 3 -6.581437, -6.578563, -6.578563, -6.581437, -6.581437, 34.271797, 34.271797, 34.273593, 34.273593, 34.271797
#> 4 -6.577664, -6.575149, -6.575149, -6.577664, -6.577664, 34.271707, 34.271707, 34.273683, 34.273683, 34.271707

# 2. Empilement NDVI de demonstration (7 dates, fevrier-juin)
ndvi_stack <- ndvi_demo_stack()

# 3. Extraction des statistiques NDVI par parcelle
ndvi_table <- extract_ndvi(ndvi_stack, demo_parcels)

# 4. Lissage de la serie temporelle
ndvi_table <- smooth_timeseries(ndvi_table, method = "moving_average")

# 5. Detection des stades phenologiques
stages <- detect_growth_stage(ndvi_table)
stages
#>   parcel_id start_growth_date  peak_date peak_ndvi senescence_date
#> 1        P1        2024-02-22 2024-04-04 0.7286444      2024-04-25
#> 2        P2        2024-02-22 2024-04-25 0.6506649      2024-06-06
#> 3        P3        2024-04-04 2024-06-06 0.8254256            <NA>
#> 4        P4        2024-04-25 2024-06-06 0.7481596            <NA>
```

### Courbes NDVI et stades phénologiques

``` r
plot_ndvi_curve(ndvi_table, stages = stages)
```

<img src="man/figures/README-curve-example-1.png" width="100%" />

### Carte NDVI

``` r
plot_ndvi_map(ndvi_stack, parcels = demo_parcels)
```

<img src="man/figures/README-map-example-1.png" width="100%" />

## Aller plus loin

Une vignette complète, incluant l’utilisation avec de vraies images
Sentinel-2 (catalogue public **Microsoft Planetary Computer**, sans clé
API), est disponible avec :

``` r
vignette("ndviMonitor-intro", package = "ndviMonitor")
```

## Données

- **Parcelles agricoles** : shapefile (`.shp`) ou GeoJSON, importés via
  \[`import_parcels()`\]. Le jeu `demo_parcels` fourni avec le package
  est synthétique mais représentatif de la plaine du Gharb (Kénitra,
  Maroc).
- **Imagerie satellite** : Sentinel-2 niveau 2A (réflectance de
  surface), bandes Rouge (B04) et Proche Infrarouge (B08), récupérées
  via le catalogue STAC public et gratuit **Microsoft Planetary
  Computer** (<https://planetarycomputer.microsoft.com/>).

## Licence

MIT © Auteurs de ndviMonitor
