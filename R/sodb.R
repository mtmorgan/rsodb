#' @rdname sodb
#'
#' @name sodb
#'
#' @title Interface to the Spatial Omics Data Base
NULL

#' @rdname sodb
#'
#' @description `info()` queries the SODB for a summary of all
#'     datasets and experiments in the Spatial Omics database. It is
#'     primarily for internal use.
#'
#' @return `info()` returns a tibble of class 'sodb_info' containing
#'     columns collection (type of dataset), dataset, and experiment.
#'
#' @examples
#' info()
#'
#' @export
info <-
    function()
{
    tbl <- .info(SERVER_ADDRESS)
    attr(tbl, "server") <- SERVER_ADDRESS
    attr(tbl, "download_time") <- Sys.time()
    class(tbl) <- c("sodb_info", "sodb", class(tbl))
    tbl
}

#' @importFrom httr GET stop_for_status content
#'
#' @importFrom dplyr tibble
.info <-
    function(server)
{
    url <- paste0(server, "/pysodb/info")
    response <- GET(url)
    stop_for_status(response)
    json <- content(response, as = "text", encoding = "UTF-8")
    tibble(
        category = .jmespath(json, "data[*][0]"),
        dataset =  .jmespath(json, "data[*][1]"),
        experiment =  .jmespath(json, "data[*][2]"),
    )
}

#' @importFrom glue glue_data_safe
#'
#' @importFrom rlang hash
.uids <-
    function(db)
{
    id <-
        db |>
        glue_data_safe("{dataset}-{experiment}")
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
        return(bind_cols(db, path = character()))
    }

    urls <-
        db |>
        glue_data_safe("{SERVER_ADDRESS}/download/{dataset}/{experiment}")

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

    bind_cols(db, path = paths)
}
