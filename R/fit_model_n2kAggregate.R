#' @rdname fit_model
#' @importFrom methods setMethod new
#' @importFrom multimput aggregate_impute
#' @include n2kAggregate_class.R
setMethod(
  f = "fit_model",
  signature = signature(x = "n2kAggregate"),
  definition = function(x, ...) {
    validObject(x)
    dots <- list(...)
    if (is.null(dots$status)) {
      dots$status <- c("new", "waiting")
    }
    if (!(status(x) %in% dots$status)) {
      return(x)
    }

    # status: "waiting"
    if (status(x) == "waiting" | is.null(x@RawImputed)) {
      parent <- get_parents(x, base = dots$base, project = dots$project)
      if (length(parent) == 0) {
        stop("Parent analysis not found")
      }
      if (length(parent) > 1) {
        stop("Multiple parents")
      }
      parent <- parent[[1]]
      parent_status <- status(parent)
      if (parent_status %in% c("new", "waiting")) {
        status(x) <- "waiting"
        return(x)
      }
      if (parent_status != "converged") {
        status(x) <- "error"
        return(x)
      }
      if (inherits(parent, "n2kInla")) {
        x@RawImputed <- parent@RawImputed
      } else if (inherits(parent, "n2kAggregate")) {
        x@RawImputed <- new(
          "rawImputed",
          Data = cbind(parent@AggregatedImputed@Covariate, Count = NA),
          Response = "Count",
          Minimum = "",
          Imputation = parent@AggregatedImputed@Imputation
        )
      } else {
        stop("cannot handle a parent of class ", class(parent))
      }
      x@AnalysisRelation$ParentStatus <- parent@AnalysisMetadata$Status
      x@AnalysisRelation$ParentStatusFingerprint <-
        parent@AnalysisMetadata$StatusFingerprint
      status(x) <- "new"
    }
    model <- try(
      aggregate_impute(
        object = x@RawImputed,
        grouping = x@AnalysisFormula[[1]] %>%
          terms() %>%
          attr("term.labels"),
        fun = x@Function,
        filter = x@Filter,
        join = x@Join
      )
    )
    if ("try-error" %in% class(model)) {
      status(x) <- "error"
      return(x)
    }
    x@AggregatedImputed <- model
    status(x) <- "converged"
    return(x)
  }
)
