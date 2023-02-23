#' @rdname sodb
#'
#' @description `datasets()` queries the SODB for all available datasets.
#'
#' @return `datasets()` returns a tibble with each row representing a
#'     dataset. Columns are include all available information on
#'     biotechnology, species, tissue, and publication.
#'
#' @examples
#' ds <- datasets()
#' ds
#' ds |>
#'     dplyr::slice(1:2) |>
#'     dplyr::glimpse()
#'
#' @export
datasets <-
    function()
{
    tbl <- .dataset_search(SERVER_ADDRESS)
    attr(tbl, "server") <- SERVER_ADDRESS
    attr(tbl, "download_time") <- Sys.time()
    class(tbl) <- c("sodb_dataset", "sodb", class(tbl))
    tbl
}

#' @importFrom httr POST content_type
#' @importFrom dplyr as_tibble mutate select everything
.dataset_search <-
    function(server)
{
    url <- paste0(server, "/dataset_search")
    body <- '{"criteria": {}}'
    response <- POST(url, body = body, content_type("application/json"))
    stop_for_status(response)
    json <- content(response, as = "text", encoding = "UTF-8")

    ## use first record to retrieve keys...
    keys <-
        jmespath(json, "keys(data[0])") |>
        fromJSON()
    ## ...and then data from all columns
    columns <- lapply(keys, function(key, json) {
        .jmespath(json, paste0("data[*].", key))
    }, json)

    ## return as tibble
    names(columns) <- keys
    tbl <-
        as_tibble(columns) |>
        mutate(
            author = gsub("\\n", "; ", .data$author),
            author = gsub("[[:space:]]+", " ", .data$author)
        ) |>
        select(
            "biotech", "species", "tissue", "n_unit",
            "author", year = "date", title = "name_long", "journal",
            "doi", "country", "access", "id", dataset = "name_short"
        )
}

#' @rdname sodb
#'
#' @description `local_dataset()` summarizes experiments in a dataset,
#'     and (optionally) retrieves all experiment files to a local
#'     cache.
#'
#' @param ds a tibble containing one (for `local_dataset()`), or
#'     several (for `cached()`) rows. `ds` should be derived from
#'     `datasets()`, potentially transformed (e.g., via `filter()`)
#'     via standard 'dplyr' operations. It must have a column
#'     `dataset`.
#'
#' @param dry.run logical(1) when `TRUE` (default), only summarize the
#'     number of experiments to be downloaded or retrieved from the
#'     cache.
#'
#' @param force logical(1) when `FALSE` (default), do not download
#'     files that have already been downloaded.
#'
#' @return `local_dataset()` returns a tibble containing the distint
#'     rows of `db`. When `dry.run = FALSE`, the tibble is annotated
#'     with a column `path` containing the path to the downloaded
#'     files.
#'
#' @importFrom dplyr .data filter distinct
#'
#' @examples
#' local_dataset <-
#'     ds |>
#'     dplyr::filter(dataset == "liu2020high") |>
#'     local_dataset(dry.run = FALSE)
#'
#' local_dataset
#'
#' @export
local_dataset <-
    function(ds, dry.run = TRUE, force = FALSE)
{
    stopifnot(
        inherits(ds, "sodb_dataset"),
        "dataset" %in% colnames(ds),
        `'ds' should have exactly 1 row (dataset)` = NROW(ds) == 1L,
        .is_scalar_logical(dry.run),
        .is_scalar_logical(force)
    )

    db <- .datasets_add_info(ds)

    if (dry.run) {
        message(
            "use `dry.run = FALSE` to retrieve ", NROW(db), " experiments"
        )
        db1 <- tibble(
            dataset = character(), experiment = character(), path = character()
        )
    } else {
        db1 <- .download(db, force)
    }

    result <- c(
        as.list(ds),
        list(experiments = db1)
    )
    class(result) <- c("local_dataset", "sodb", class(tibble()))
    result
}

#' @importFrom dplyr left_join
.datasets_add_info <-
    function(ds)
{
    ds |>
        left_join(info(), by = c(dataset = "dataset"), multiple = "all") |>
        select("dataset", "experiment") |>
        distinct()
}

#' @rdname sodb
#'
#' @description `experiments()` queries a local dataset for experiment
#'     file paths. These paths can be used in down-stream analysis.
#'
#' @param lds an object derived from `local_dataset()`.
#'
#' @return `experiments()` returns a tibble with columns summarizing
#'     the dataset, experiment, and paths to locally cached files
#'
#' @examples
#' local_dataset |>
#'     experiments()
#'
#' @export
experiments <-
    function(lds)
{
    stopifnot(inherits(lds, "local_dataset"))
    lds$experiments
}
.experiment <-
    function(x)
{
    stopifnot(inherits(x, "local_dataset"))
    experiments(x)$experiment
}

.path <-
    function(x, i)
{
    stopifnot(inherits(x, "local_dataset"))
    experiments(x)$path
}

#' @importFrom utils head
#'
#' @export
print.local_dataset <-
    function(x, ...)
{
    fields <-setdiff(names(x), "experiments")
    fields_text <- sprintf("%s: %s\n", fields, x[fields])
    cat("class: ", head(class(x), 1L), "\n", sep = "")

    ## individual fields
    for (field in fields) {
        txt <- sprintf("%s: %s", field, x[[field]])
        cat(paste(strwrap(txt, exdent = 4L), collapse = "\n"), "\n", sep = "")
    }

    ## experiments
    txt <- sprintf(
        "experiments(): %s",
        paste(.experiment(x), collapse = ", ")
    )
    cat(paste(strwrap(txt, exdent = 4L), collapse = "\n"), "\n", sep = "")
}

#' @rdname sodb
#'
#' @description `cached()` identifies datasets and experiments that
#'     have been downloaded to the local cache.
#'
#' @return `cached()` returns a tibble containing `info()` filtered to
#'     contain just the experiments that have been downloaded. The
#'     return value includes a column `path` to the downloaded file.
#'
#' @importFrom dplyr select any_of right_join
#'
#' @examples
#' cached()
#'
#' @export
cached <-
    function(ds = datasets())
{
    stopifnot(
        inherits(ds, "sodb_dataset"),
        "dataset" %in% colnames(ds)
    )

    db <- .datasets_add_info(ds)

    db <- bind_cols(db, uid = .uids(db))
    paths <- dir(.cache_directory(), full.names = TRUE)
    tbl <- tibble(
        path = paths,
        uid = sub(".h5ad", "", basename(paths), fixed = TRUE)
    )

    right_join(db, tbl, by = "uid") |>
        select(!any_of("uid"))
}
