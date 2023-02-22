
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rsodb

<!-- badges: start -->
<!-- badges: end -->

rsodb provides an *R* interface to the Spatial Omics database
[SODB](https://gene.ai.tencent.com/SpatialOmics). The interface is
rudimentary, allowing simple discovery and retrieval of datasets similar
to the functionality of the Python client
[pysodb](https://pysodb.readthedocs.io/en/latest/#).

## Installation

Install the development version of rsodb with:

``` r
if (!nzchar(system.file(package = "BiocManager")))
    install.packages("BiocManager", repos = "https://cran.r-project.org")
if (!nzchar(system.file(package = "remotes")))
    BiocManager::install("remotes")
BiocManager::install("mtmorgan/rsodb")
```

## Example

Load the rsodb and dplyr packages

``` r
library(rsodb)
library(dplyr)
```

Discover all experiments available

``` r
db <- sodb()
db
#> # A tibble: 2,755 × 3
#>    Category           Dataset     Experiment                  
#>    <chr>              <chr>       <chr>                       
#>  1 Spatial MultiOmics liu2020high GSM4202309_0719aL_protein   
#>  2 Spatial MultiOmics liu2020high GSM4202310_0725e10aL_protein
#>  3 Spatial MultiOmics liu2020high E11_lower_body              
#>  4 Spatial MultiOmics liu2020high E10_whole_gene_best         
#>  5 Spatial MultiOmics liu2020high E10_eye_and_nearby          
#>  6 Spatial MultiOmics liu2020high E10_whole_gene              
#>  7 Spatial MultiOmics liu2020high E10_whole_protein           
#>  8 Spatial MultiOmics liu2020high E10_brain_gene_25um         
#>  9 Spatial MultiOmics liu2020high GSM4189615_0719cL_gene      
#> 10 Spatial MultiOmics liu2020high GSM4189612_0628cL_gene      
#> # … with 2,745 more rows
```

Filter to experiments of interest using ‘standard’ dplyr verbs, and
download experiments to a local cache.

``` r
local_db <-
    db |>
    dplyr::filter(
        Dataset == "liu2020high",
        startsWith(Experiment, "E1")
    ) |>
    download(dry.run = FALSE)
#> downloading 0 experiments; 8 cached
local_db
#> # A tibble: 8 × 4
#>   Category           Dataset     Experiment             Path                    
#>   <chr>              <chr>       <chr>                  <chr>                   
#> 1 Spatial MultiOmics liu2020high E11_lower_body         /Users/ma38727/Library/…
#> 2 Spatial MultiOmics liu2020high E10_whole_gene_best    /Users/ma38727/Library/…
#> 3 Spatial MultiOmics liu2020high E10_eye_and_nearby     /Users/ma38727/Library/…
#> 4 Spatial MultiOmics liu2020high E10_whole_gene         /Users/ma38727/Library/…
#> 5 Spatial MultiOmics liu2020high E10_whole_protein      /Users/ma38727/Library/…
#> 6 Spatial MultiOmics liu2020high E10_brain_gene_25um    /Users/ma38727/Library/…
#> 7 Spatial MultiOmics liu2020high E11_lower_body_fig6    /Users/ma38727/Library/…
#> 8 Spatial MultiOmics liu2020high E10_brain_protein_25um /Users/ma38727/Library/…
```

Experiments are **not** downloaded by default; use `dry.run = TRUE` to
download the experiments. Experiments are downloaded only once and
stored in a local cache, use `force = TRUE` to force experiments to be
downloaded again.

## Next steps

Files from SODB are in ‘AnnData’ format, with extension `.h5ad`. These
are easily read into *R* using the
[zellkonverter](https://bioconductor.org/packages/zellkonverter)
package. Make sure it is installed and attached to the current *R*
session (n.b., installing zellkonverter can be a ‘heavy’ operation if
one is not using [Bioconductor](https://bioconductor.org), because it
depends on many core packages used in single-cell and spatial omics; the
payoff is that one is now ready to perform advanced analysis single-cell
and spatial analysis).

``` r
if (!nzchar(system.file(package = "zellkonverter")))
    BiocManager::install("zellkonverter")
library(zellkonverter)
#> Registered S3 method overwritten by 'zellkonverter':
#>   method                from      
#>   py_to_r.numpy.ndarray reticulate
```

For example, load the first experiment from the ‘liu2020high’ dataset.

``` r
zellkonverter::readH5AD(local_db$Path[[1]], use_hdf5 = TRUE)
#> class: SingleCellExperiment 
#> dim: 21890 1662 
#> metadata(8): hvg leiden ... spatial_neighbors umap
#> assays(1): X
#> rownames(21890): Gm37180 Gm37363 ... mt-Tt mt-Tp
#> rowData names(5): highly_variable means dispersions dispersions_norm
#>   varm
#> colnames(1662): 10x35 10x34 ... 9x2 9x1
#> colData names(1): leiden
#> reducedDimNames(3): X_pca X_umap spatial
#> mainExpName: NULL
#> altExpNames(0):
```

## sessionInfo

The following summarizes software used to render this document.

``` r
sessioninfo::session_info()
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R Under development (unstable) (2023-02-21 r83887)
#>  os       macOS Monterey 12.6.2
#>  system   aarch64, darwin21.6.0
#>  ui       X11
#>  language (EN)
#>  collate  en_US.UTF-8
#>  ctype    en_US.UTF-8
#>  tz       America/New_York
#>  date     2023-02-22
#>  pandoc   2.17.1.1 @ /Users/ma38727/homebrew/bin/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package              * version     date (UTC) lib source
#>  basilisk               1.11.2      2022-11-09 [2] Bioconductor
#>  basilisk.utils         1.11.2      2023-01-31 [2] Bioconductor
#>  Biobase                2.59.0      2022-11-01 [2] Bioconductor
#>  BiocGenerics           0.45.0      2022-11-01 [2] Bioconductor
#>  bitops                 1.0-7       2021-04-24 [2] CRAN (R 4.3.0)
#>  cli                    3.6.0       2023-01-09 [2] CRAN (R 4.3.0)
#>  curl                   5.0.0       2023-01-12 [2] CRAN (R 4.3.0)
#>  DelayedArray           0.25.0      2022-11-01 [2] Bioconductor
#>  digest                 0.6.31      2022-12-11 [2] CRAN (R 4.3.0)
#>  dir.expiry             1.7.0       2022-11-01 [2] Bioconductor
#>  dplyr                * 1.1.0       2023-01-29 [2] CRAN (R 4.3.0)
#>  evaluate               0.20        2023-01-17 [2] CRAN (R 4.3.0)
#>  fansi                  1.0.4       2023-01-22 [2] CRAN (R 4.3.0)
#>  fastmap                1.1.0       2021-01-25 [2] CRAN (R 4.3.0)
#>  filelock               1.0.2       2018-10-05 [2] CRAN (R 4.3.0)
#>  generics               0.1.3       2022-07-05 [2] CRAN (R 4.3.0)
#>  GenomeInfoDb           1.35.15     2023-02-02 [2] Bioconductor
#>  GenomeInfoDbData       1.2.9       2022-11-04 [2] Bioconductor
#>  GenomicRanges          1.51.4      2022-12-15 [2] Bioconductor
#>  glue                   1.6.2       2022-02-24 [2] CRAN (R 4.3.0)
#>  HDF5Array              1.27.0      2022-11-01 [2] Bioconductor
#>  here                   1.0.1       2020-12-13 [2] CRAN (R 4.3.0)
#>  htmltools              0.5.4       2022-12-07 [2] CRAN (R 4.3.0)
#>  httr                   1.4.4       2022-08-17 [2] CRAN (R 4.3.0)
#>  IRanges                2.33.0      2022-11-01 [2] Bioconductor
#>  jsonlite               1.8.4       2022-12-06 [2] CRAN (R 4.3.0)
#>  knitr                  1.42        2023-01-25 [2] CRAN (R 4.3.0)
#>  lattice                0.20-45     2021-09-22 [3] CRAN (R 4.3.0)
#>  lifecycle              1.0.3       2022-10-07 [2] CRAN (R 4.3.0)
#>  magrittr               2.0.3       2022-03-30 [2] CRAN (R 4.3.0)
#>  Matrix                 1.5-3       2022-11-11 [3] CRAN (R 4.3.0)
#>  MatrixGenerics         1.11.0      2022-11-01 [2] Bioconductor
#>  matrixStats            0.63.0      2022-11-18 [2] CRAN (R 4.3.0)
#>  pillar                 1.8.1       2022-08-19 [2] CRAN (R 4.3.0)
#>  pkgconfig              2.0.3       2019-09-22 [2] CRAN (R 4.3.0)
#>  png                    0.1-8       2022-11-29 [2] CRAN (R 4.3.0)
#>  R6                     2.5.1       2021-08-19 [2] CRAN (R 4.3.0)
#>  Rcpp                   1.0.10      2023-01-22 [2] CRAN (R 4.3.0)
#>  RCurl                  1.98-1.10   2023-01-27 [2] CRAN (R 4.3.0)
#>  reticulate             1.28        2023-01-27 [2] CRAN (R 4.3.0)
#>  rhdf5                  2.43.0      2022-12-28 [2] Bioconductor
#>  rhdf5filters           1.11.0      2022-11-01 [2] Bioconductor
#>  Rhdf5lib               1.21.0      2022-12-31 [2] Bioconductor
#>  rjsoncons              1.0.0       2022-09-29 [2] CRAN (R 4.3.0)
#>  rlang                  1.0.6       2022-09-24 [2] CRAN (R 4.3.0)
#>  rmarkdown              2.20        2023-01-19 [2] CRAN (R 4.3.0)
#>  rprojroot              2.0.3       2022-04-02 [2] CRAN (R 4.3.0)
#>  rsodb                * 0.0.0.90000 2023-02-22 [1] local
#>  S4Vectors              0.37.3      2022-12-07 [2] Bioconductor
#>  sessioninfo            1.2.2       2021-12-06 [2] CRAN (R 4.3.0)
#>  SingleCellExperiment   1.21.0      2022-11-01 [2] Bioconductor
#>  SummarizedExperiment   1.29.1      2022-11-04 [2] Bioconductor
#>  tibble                 3.1.8       2022-07-22 [2] CRAN (R 4.3.0)
#>  tidyselect             1.2.0       2022-10-10 [2] CRAN (R 4.3.0)
#>  utf8                   1.2.3       2023-01-31 [2] CRAN (R 4.3.0)
#>  vctrs                  0.5.2       2023-01-23 [2] CRAN (R 4.3.0)
#>  withr                  2.5.0       2022-03-03 [2] CRAN (R 4.3.0)
#>  xfun                   0.37        2023-01-31 [2] CRAN (R 4.3.0)
#>  XVector                0.39.0      2022-11-01 [2] Bioconductor
#>  yaml                   2.3.7       2023-01-23 [2] CRAN (R 4.3.0)
#>  zellkonverter        * 1.9.0       2022-11-01 [2] Bioconductor
#>  zlibbioc               1.45.0      2022-11-01 [2] Bioconductor
#> 
#>  [1] /private/var/folders/yn/gmsh_22s2c55v816r6d51fx1tnyl61/T/Rtmp1CcYpm/temp_libpath171614c7874f
#>  [2] /Users/ma38727/Library/R/arm64/4.3-3.17
#>  [3] /Users/ma38727/bin/R-devel/library
#> 
#> ─ Python configuration ───────────────────────────────────────────────────────
#>  python:         /Users/ma38727/Library/Caches/org.R-project.R/R/basilisk/1.11.2/zellkonverter/1.9.0/zellkonverterAnnDataEnv-0.8.0/bin/python
#>  libpython:      /Users/ma38727/Library/Caches/org.R-project.R/R/basilisk/1.11.2/zellkonverter/1.9.0/zellkonverterAnnDataEnv-0.8.0/lib/libpython3.8.dylib
#>  pythonhome:     /Users/ma38727/Library/Caches/org.R-project.R/R/basilisk/1.11.2/zellkonverter/1.9.0/zellkonverterAnnDataEnv-0.8.0:/Users/ma38727/Library/Caches/org.R-project.R/R/basilisk/1.11.2/zellkonverter/1.9.0/zellkonverterAnnDataEnv-0.8.0
#>  version:        3.8.13 | packaged by conda-forge | (default, Mar 25 2022, 06:05:16)  [Clang 12.0.1 ]
#>  numpy:          /Users/ma38727/Library/Caches/org.R-project.R/R/basilisk/1.11.2/zellkonverter/1.9.0/zellkonverterAnnDataEnv-0.8.0/lib/python3.8/site-packages/numpy
#>  numpy_version:  1.22.3
#>  
#>  NOTE: Python version was forced by use_python function
#> 
#> ──────────────────────────────────────────────────────────────────────────────
```
