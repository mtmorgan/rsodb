
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

Discover all available datasets.

``` r
ds <- datasets()
ds
#> # A tibble: 151 × 13
#>       id biotech  species tissue n_unit author  year title journal doi   country
#>    <int> <chr>    <chr>   <chr>   <int> <chr>  <int> <chr> <chr>   <chr> <chr>  
#>  1     0 Slide-s… Mouse(… Testi… 2.07e5 Chen,…  2021 Diss… Cell R… http… USA    
#>  2     1 Slide-s… Mouse(… Hippo… 2.33e5 Stick…  2020 High… Nature… 10.1… USA    
#>  3     2 Slide-s… Mouse(… nan(9… 2.56e6 Rodri…  2019 Slid… Science 10.1… USA    
#>  4     3 10X Vis… Mouse(… Intes… 1.37e4 Parig…  2022 The … Nature… 10.1… USA    
#>  5     4 10X Vis… Mouse(… Liver… 2.42e4 Guill…  2022 Spat… Cell    10.1… Belgium
#>  6     6 10X Vis… Human(… Brain… 4.77e4 Mayna…  2021 Tran… Nature… 10.1… USA    
#>  7     7 10X Vis… Chicke… Heart… 6.60e3 Mantr…  2021 Spat… Nature… 10.1… USA    
#>  8     8 10X Vis… zebraf… melan… 7.28e3 Hunte…  2021 Spat… Nature… 10.1… USA    
#>  9     9 10X Vis… Mouse(… Liver… 8.75e3 Hilde…  2021 Spat… Nature… 10.1… Sweden 
#> 10    11 10X Vis… Human(… Intes… 2.12e4 Fawkn…  2021 Spat… Cell    10.1… UK     
#> # … with 141 more rows, and 2 more variables: access <chr>, dataset <chr>
ds |> glimpse()
#> Rows: 151
#> Columns: 13
#> $ id      <int> 0, 1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 14, 15, 16, 17, 18, 19, 20,…
#> $ biotech <chr> "Slide-seqV2", "Slide-seqV2", "Slide-seq", "10X Visium", "10X …
#> $ species <chr> "Mouse(6)", "Mouse(6)", "Mouse(96)", "Mouse(4)", "Mouse(15)", …
#> $ tissue  <chr> "Testis(6)", "Hippocampus(2),neocortex(1),Cerebellum(1),Somato…
#> $ n_unit  <int> 207335, 232963, 2558150, 13715, 24179, 47681, 6596, 7281, 8746…
#> $ author  <chr> "Chen, H.; Murray, E.; Sinha, A.; Laumas, A.; Li, J.; Lesman, …
#> $ year    <int> 2021, 2020, 2019, 2022, 2022, 2021, 2021, 2021, 2021, 2021, 20…
#> $ title   <chr> "Dissecting mammalian spermatogenesis using spatial transcript…
#> $ journal <chr> "Cell Reports", "Nature Biotechnology", "Science", "Nature Com…
#> $ doi     <chr> "https://doi.org/10.1016/j.celrep.2021.109915", "10.1038/s4158…
#> $ country <chr> "USA", "USA", "USA", "USA", "Belgium", "USA", "USA", "USA", "S…
#> $ access  <chr> "https://www.dropbox.com/s/ygzpj0d0oh67br0/Testis_Slideseq_Dat…
#> $ dataset <chr> "chen2021dissecting", "stickels2020highly", "rodriques2019slid…
```

Filter datasets to those of interest using ‘standard’ dplyr verbs, and
use `local_dataset()` to retrieve experiment results to a local file
cache.

``` r
local_dataset <-
    ds |>
    dplyr::filter(dataset == "liu2020high") |>
    local_dataset(dry.run = FALSE)
#> downloading 0 experiments; 15 cached
local_dataset
#> class: local_dataset
#> id: 76
#> biotech: DBiT-seq
#> species: Mouse(15)
#> tissue: Embryo(15)
#> n_unit: 24769
#> author: Liu, Yang; Yang, Mingyu; Deng, Yanxiang; Su, Graham; Enninful,
#>     Archibald; Guo, Cindy C.; Tebaldi, Toma; Zhang, Di; Kim, Dongjoo;
#>     Bai, Zhiliang; Norris, Eileen; Pan, Alisia; Li, Jiatong; Xiao,
#>     Yang; Halene, Stephanie; Fan, Rong
#> year: 2020
#> title: High-Spatial-Resolution Multi-Omics Sequencing via Deterministic
#>     Barcoding in Tissue
#> journal: Cell
#> doi: 10.1016/j.cell.2020.10.026
#> country: USA
#> access: https://www.ncbi.nlm.nih.gov/geo/query/ acc.cgi?acc=GSE137986
#> dataset: liu2020high
#> experiments(): GSM4202309_0719aL_protein, GSM4202310_0725e10aL_protein,
#>     E11_lower_body, E10_whole_gene_best, E10_eye_and_nearby,
#>     E10_whole_gene, E10_whole_protein, E10_brain_gene_25um,
#>     GSM4189615_0719cL_gene, GSM4189612_0628cL_gene,
#>     GSM4364245_E11-FL-2L_gene, E11_lower_body_fig6,
#>     GSM4364244_E11-FL-1L_gene, GSM4189613_0702cL_gene,
#>     E10_brain_protein_25um
```

Experiments are **not** downloaded by default; use `dry.run = TRUE` to
download the experiments. Experiments are downloaded only once and
stored in a local cache, use `force = TRUE` to force experiments to be
downloaded again.

Once downloaded, the cached location of individual files are available
with `experiments()`

``` r
experiments(local_dataset)
#> # A tibble: 15 × 3
#>    dataset     experiment                   path                                
#>    <chr>       <chr>                        <chr>                               
#>  1 liu2020high GSM4202309_0719aL_protein    /Users/ma38727/Library/Caches/org.R…
#>  2 liu2020high GSM4202310_0725e10aL_protein /Users/ma38727/Library/Caches/org.R…
#>  3 liu2020high E11_lower_body               /Users/ma38727/Library/Caches/org.R…
#>  4 liu2020high E10_whole_gene_best          /Users/ma38727/Library/Caches/org.R…
#>  5 liu2020high E10_eye_and_nearby           /Users/ma38727/Library/Caches/org.R…
#>  6 liu2020high E10_whole_gene               /Users/ma38727/Library/Caches/org.R…
#>  7 liu2020high E10_whole_protein            /Users/ma38727/Library/Caches/org.R…
#>  8 liu2020high E10_brain_gene_25um          /Users/ma38727/Library/Caches/org.R…
#>  9 liu2020high GSM4189615_0719cL_gene       /Users/ma38727/Library/Caches/org.R…
#> 10 liu2020high GSM4189612_0628cL_gene       /Users/ma38727/Library/Caches/org.R…
#> 11 liu2020high GSM4364245_E11-FL-2L_gene    /Users/ma38727/Library/Caches/org.R…
#> 12 liu2020high E11_lower_body_fig6          /Users/ma38727/Library/Caches/org.R…
#> 13 liu2020high GSM4364244_E11-FL-1L_gene    /Users/ma38727/Library/Caches/org.R…
#> 14 liu2020high GSM4189613_0702cL_gene       /Users/ma38727/Library/Caches/org.R…
#> 15 liu2020high E10_brain_protein_25um       /Users/ma38727/Library/Caches/org.R…
```

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
local_path <-
    experiments(local_dataset) |>
    ## select the first experiment
    slice(1) |>
    pull("path")
zellkonverter::readH5AD(local_path, use_hdf5 = TRUE)
#> class: SingleCellExperiment 
#> dim: 22 2500 
#> metadata(7): leiden leiden_colors ... spatial_neighbors umap
#> assays(1): X
#> rownames(22): CD102-ICAM2 CD117-KIT ... CD326-Ep-CAM
#>   PanendothelialCellAntigen
#> rowData names(1): varm
#> colnames(2500): 41x1 41x10 ... 42x8 42x9
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
#>  date     2023-02-23
#>  pandoc   2.17.1.1 @ /Users/ma38727/homebrew/bin/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package              * version    date (UTC) lib source
#>  basilisk               1.11.2     2022-11-09 [2] Bioconductor
#>  basilisk.utils         1.11.2     2023-01-31 [2] Bioconductor
#>  Biobase                2.59.0     2022-11-01 [2] Bioconductor
#>  BiocGenerics           0.45.0     2022-11-01 [2] Bioconductor
#>  bitops                 1.0-7      2021-04-24 [2] CRAN (R 4.3.0)
#>  cli                    3.6.0      2023-01-09 [2] CRAN (R 4.3.0)
#>  curl                   5.0.0      2023-01-12 [2] CRAN (R 4.3.0)
#>  DelayedArray           0.25.0     2022-11-01 [2] Bioconductor
#>  digest                 0.6.31     2022-12-11 [2] CRAN (R 4.3.0)
#>  dir.expiry             1.7.0      2022-11-01 [2] Bioconductor
#>  dplyr                * 1.1.0      2023-01-29 [2] CRAN (R 4.3.0)
#>  evaluate               0.20       2023-01-17 [2] CRAN (R 4.3.0)
#>  fansi                  1.0.4      2023-01-22 [2] CRAN (R 4.3.0)
#>  fastmap                1.1.0      2021-01-25 [2] CRAN (R 4.3.0)
#>  filelock               1.0.2      2018-10-05 [2] CRAN (R 4.3.0)
#>  generics               0.1.3      2022-07-05 [2] CRAN (R 4.3.0)
#>  GenomeInfoDb           1.35.15    2023-02-02 [2] Bioconductor
#>  GenomeInfoDbData       1.2.9      2022-11-04 [2] Bioconductor
#>  GenomicRanges          1.51.4     2022-12-15 [2] Bioconductor
#>  glue                   1.6.2      2022-02-24 [2] CRAN (R 4.3.0)
#>  HDF5Array              1.27.0     2022-11-01 [2] Bioconductor
#>  here                   1.0.1      2020-12-13 [2] CRAN (R 4.3.0)
#>  htmltools              0.5.4      2022-12-07 [2] CRAN (R 4.3.0)
#>  httr                   1.4.4      2022-08-17 [2] CRAN (R 4.3.0)
#>  IRanges                2.33.0     2022-11-01 [2] Bioconductor
#>  jsonlite               1.8.4      2022-12-06 [2] CRAN (R 4.3.0)
#>  knitr                  1.42       2023-01-25 [2] CRAN (R 4.3.0)
#>  lattice                0.20-45    2021-09-22 [3] CRAN (R 4.3.0)
#>  lifecycle              1.0.3      2022-10-07 [2] CRAN (R 4.3.0)
#>  magrittr               2.0.3      2022-03-30 [2] CRAN (R 4.3.0)
#>  Matrix                 1.5-3      2022-11-11 [3] CRAN (R 4.3.0)
#>  MatrixGenerics         1.11.0     2022-11-01 [2] Bioconductor
#>  matrixStats            0.63.0     2022-11-18 [2] CRAN (R 4.3.0)
#>  pillar                 1.8.1      2022-08-19 [2] CRAN (R 4.3.0)
#>  pkgconfig              2.0.3      2019-09-22 [2] CRAN (R 4.3.0)
#>  png                    0.1-8      2022-11-29 [2] CRAN (R 4.3.0)
#>  R6                     2.5.1      2021-08-19 [2] CRAN (R 4.3.0)
#>  Rcpp                   1.0.10     2023-01-22 [2] CRAN (R 4.3.0)
#>  RCurl                  1.98-1.10  2023-01-27 [2] CRAN (R 4.3.0)
#>  reticulate             1.28       2023-01-27 [2] CRAN (R 4.3.0)
#>  rhdf5                  2.43.0     2022-12-28 [2] Bioconductor
#>  rhdf5filters           1.11.0     2022-11-01 [2] Bioconductor
#>  Rhdf5lib               1.21.0     2022-12-31 [2] Bioconductor
#>  rjsoncons              1.0.0      2022-09-29 [2] CRAN (R 4.3.0)
#>  rlang                  1.0.6      2022-09-24 [2] CRAN (R 4.3.0)
#>  rmarkdown              2.20       2023-01-19 [2] CRAN (R 4.3.0)
#>  rprojroot              2.0.3      2022-04-02 [2] CRAN (R 4.3.0)
#>  rsodb                * 0.0.0.9001 2023-02-23 [1] local
#>  S4Vectors              0.37.3     2022-12-07 [2] Bioconductor
#>  sessioninfo            1.2.2      2021-12-06 [2] CRAN (R 4.3.0)
#>  SingleCellExperiment   1.21.0     2022-11-01 [2] Bioconductor
#>  SummarizedExperiment   1.29.1     2022-11-04 [2] Bioconductor
#>  tibble                 3.1.8      2022-07-22 [2] CRAN (R 4.3.0)
#>  tidyselect             1.2.0      2022-10-10 [2] CRAN (R 4.3.0)
#>  utf8                   1.2.3      2023-01-31 [2] CRAN (R 4.3.0)
#>  vctrs                  0.5.2      2023-01-23 [2] CRAN (R 4.3.0)
#>  withr                  2.5.0      2022-03-03 [2] CRAN (R 4.3.0)
#>  xfun                   0.37       2023-01-31 [2] CRAN (R 4.3.0)
#>  XVector                0.39.0     2022-11-01 [2] Bioconductor
#>  yaml                   2.3.7      2023-01-23 [2] CRAN (R 4.3.0)
#>  zellkonverter        * 1.9.0      2022-11-01 [2] Bioconductor
#>  zlibbioc               1.45.0     2022-11-01 [2] Bioconductor
#> 
#>  [1] /private/var/folders/yn/gmsh_22s2c55v816r6d51fx1tnyl61/T/Rtmp1CcYpm/temp_libpath171617424a8cf
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
