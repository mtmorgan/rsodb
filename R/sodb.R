SERVER_ADDRESS <-
    "https://gene.ai.tencent.com/SpatialOmics/api/pysodb"

#' @importFrom tools R_user_dir
.cache_directory <-
    function()
{
    cache <- R_user_dir("rsodb", "cache")
    if (!dir.exists(cache))
        dir.create(cache)

    cache
}

#' @rdname sodb
#'
#' @title Interface to the Spatial Omics Data Base
#'
#' @description `sodb()` returns a tibble containing all datasets and
#'     experiments in the Spatial Omics database.
#'
#' @return `sodb()` returns a tibble of class 'sodb' containing
#'     columns Collection (type of dataset), Dataset, and Experiment.
#'
#' @examples
#' db <- sodb()
#' db
#'
#' @export
sodb <-
    function()
{
    tbl <- .info(SERVER_ADDRESS)
    attr(tbl, "server") <- SERVER_ADDRESS
    attr(tbl, "download_time") <- Sys.time()
    class(tbl) <- c("sodb", class(tbl))
    tbl
}

#' @importFrom httr GET stop_for_status content
#'
#' @importFrom rjsoncons jmespath
#'
#' @importFrom jsonlite fromJSON
#'
#' @importFrom dplyr tibble
.info <-
    function(server)
{
    url <- paste0(server, "/info")
    response <- GET(url)
    stop_for_status(response)
    json <- content(response, as = "text", encoding = "UTF-8")
    tibble(
        Category = jmespath(json, "data[*][0]") |> fromJSON(),
        Dataset =  jmespath(json, "data[*][1]") |> fromJSON(),
        Experiment =  jmespath(json, "data[*][2]") |> fromJSON()
    )
}

.server <-
    function(db = sodb())
{
    stopifnot(inherits(db, "sodb"))
    attr(db, "server")
}

#' @rdname sodb
#'
#' @description `download()` retrieves experiments to a local cache.
#'
#' @param db a tibble containing datasets and experiments. `db` should
#'     be derived from `sodb()`, potentially transformed (e.g., via
#'     `filter()`) via standard 'dplyr' operations. It must have
#'     columns `Dataset` and `Experiment`.
#'
#' @param dry.run logical(1) when `TRUE` (default), only summarize the
#'     number of experiments to be downloaded or retrieved from the
#'     cache.
#'
#' @param force logical(1) when `FALSE` (default), do not download
#'     files that have already been downloaded.
#'
#' @return `download()` returns a tibble containing the distint rows
#'     of `db`. When `dry.run = FALSE`, the tibble is annotated with a
#'     column `Path` containing the path to the downloaded files.
#'
#' @importFrom dplyr .data filter distinct
#'
#' @examples
#' db |>
#'     dplyr::filter(
#'         Dataset == "liu2020high",
#'         startsWith(Experiment, "E1")
#'     ) |>
#'     download(dry.run = FALSE)
#' 
#' @export
download <-
    function(db = sodb(), dry.run = TRUE, force = FALSE)
{
    stopifnot(
        inherits(db, "sodb"),
        c("Dataset", "Experiment") %in% colnames(db),
        .is_scalar_logical(dry.run),
        .is_scalar_logical(force)
    )

    db <- distinct(db)

    if (dry.run) {
        message("use `dry.run = FALSE` to retrieve ", NROW(db), " experiments")
        db
    } else {
        .download(db, force)
    }
}

#' @importFrom glue glue_data_safe
#'
#' @importFrom rlang hash
.uids <-
    function(db)
{
    id <-
        db |>
        glue_data_safe("{Dataset}-{Experiment}")
    ## hash to avoid possible invalid file names across OS
    vapply(id, hash, character(1))
}

#' @importFrom dplyr bind_cols
#'
#' @importFrom httr write_disk progress
.download <-
    function(db, force)
{
    if (NROW(db) == 0L) {
        message("no experiments to download")
        return(bind_cols(db, Path = character()))
    }

    urls <-
        db |>
        glue_data_safe("{SERVER_ADDRESS}/download/{Dataset}/{Experiment}")

    uids <- .uids(db)
    paths <- file.path(.cache_directory(), paste0(uids, ".h5ad"))

    n_download <- length(paths) - ifelse(force, 0L, sum(file.exists(paths)))
    message(
        "downloading ", n_download, " experiments; ",
        length(paths) - n_download, " cached"
    )
    Map(function(url, path) {
        if (force || !file.exists(path))
            GET(url, write_disk(path, overwrite = TRUE), progress())
    }, urls, paths)

    bind_cols(db, Path = paths)
}

#' @rdname sodb
#'
#' @description `cached()` filters `db` to contain only datasets and
#'     experiments that have been downloaded to the local cache, and
#'     annotates the filtered tibble to contain the path to the cached
#'     h5ad files.
#'
#' @return `cached()` returns a tibble containg `db` filtered to
#'     contain just the experiments that have been downloaded. The
#'     return value includes a column `Path` with the path to the
#'     downloaded file.
#'
#' @importFrom dplyr select any_of right_join
#'
#' @examples
#' db |>
#'     cached()
#'
#' @export
cached <-
    function(db = sodb())
{
    stopifnot(
        inherits(db, "sodb"),
        c("Dataset", "Experiment") %in% colnames(db)
    )

    db <- bind_cols(db, uid = .uids(db))
    paths <- dir(.cache_directory(), full.names = TRUE)
    tbl <- tibble(
        Path = paths,
        uid = sub(".h5ad", "", basename(paths), fixed = TRUE)
    )

    right_join(db, tbl, by = "uid") |>
        select(!any_of("uid"))
}        
