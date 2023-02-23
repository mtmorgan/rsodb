SERVER_ADDRESS <-
    "https://gene.ai.tencent.com/SpatialOmics/api"

.server <-
    function(x)
{
    stopifnot(inherits(x, "sodb"))
    attr(x, "server")
}

.is_scalar <- function(x)
    length(x) == 1L && !is.na(x)

.is_scalar_logical <- function(x)
    is.logical(x) && .is_scalar(x)

#' @importFrom tools R_user_dir
.cache_directory <-
    function()
{
    cache <- R_user_dir("rsodb", "cache")
    if (!dir.exists(cache))
        dir.create(cache)

    cache
}

#' @importFrom rjsoncons jmespath
#'
#' @importFrom jsonlite fromJSON
.jmespath <-
    function(json, path)
{
    jmespath(json, path) |>
        fromJSON()
}
