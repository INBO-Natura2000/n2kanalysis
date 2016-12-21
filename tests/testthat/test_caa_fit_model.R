context("fit_model")
describe("fit_model() on GlmerPoisson based objects", {
  temp.dir <- tempdir()
  data(cbpp, package = "lme4")
  cbpp$Weight <- cbpp$size
  cbpp$DatasourceID <- sha1(letters)
  cbpp$ObservationID <- seq_len(nrow(cbpp))
  this.analysis.date <- as.POSIXct("2015-01-01 12:13:14", tz = "UTC")
  this.seed <- 1L
  object <- n2k_glmer_poisson(
    scheme.id = sha1(letters),
    species.group.id = sha1(letters),
    location.group.id = sha1(letters),
    model.type = "glmer poisson: period + herd",
    formula = "incidence ~ offset(log(size)) + period + (1|herd)",
    first.imported.year = 1990L,
    last.imported.year = 2015L,
    analysis.date = this.analysis.date,
    seed = this.seed,
    data = cbpp
  )
  weighted.object <- n2k_glmer_poisson(
    scheme.id = sha1(letters),
    species.group.id = sha1(letters),
    location.group.id = sha1(letters),
    model.type = "weighted glmer poisson: period + herd",
    formula = "incidence ~ offset(log(size)) + period + (1|herd)",
    first.imported.year = 1990L,
    last.imported.year = 2015L,
    analysis.date = this.analysis.date,
    seed = this.seed,
    data = cbpp
  )
  object.fit <- fit_model(object)
  weighted.object.fit <- fit_model(weighted.object)
  cat(
    "\nobject.file <- \"", get_file_fingerprint(object), "\"\n",
    "weighted.object.file <- \"",
      get_file_fingerprint(weighted.object), "\"\n",
    sep = ""
  )
  # 32-bit windows
  object.file <- "87a9ee64c60440d7b31d1734c1e46250ffbad80b"
  weighted.object.file <- "a995b4add88cc08e755c10a842abc29e83bfe65f"

  it("returns the same file fingerprints on 32-bit and 64-bit", {
    expect_identical(object.file, get_file_fingerprint(object))
    expect_identical(
      weighted.object.file,
      get_file_fingerprint(weighted.object)
    )
  })
  it("doesn't alter the file fingerprint when fitting a model", {
    expect_identical(
      get_file_fingerprint(object),
      get_file_fingerprint(object.fit)
    )
    expect_identical(
      get_file_fingerprint(weighted.object),
      get_file_fingerprint(weighted.object.fit)
    )
  })
  it("returns valid objects", {
    expect_that(
      validObject(object.fit),
      is_true()
    )
    expect_that(
      validObject(weighted.object.fit),
      is_true()
    )
  })
  it("works with objects saved in rds files", {
    filename <- store_model(object, base = temp.dir, project = "fit_model")
    expect_identical(status(filename)$Status, "new")
    fit_model(filename)
    filename <- gsub("new", "converged", filename)
    expect_identical(
      status(filename)$Status,
      "converged"
    )
    filename <- store_model(weighted.object, base = temp.dir, project = "fit_model")
    expect_identical(status(filename)$Status, "new")
    fit_model(filename)
    filename <- gsub("new", "converged", filename)
    expect_identical(
      status(filename)$Status,
      "converged"
    )
  })

  # clean temp files
  file.remove(list.files(temp.dir, recursive = TRUE, full.names = TRUE))
})

describe("fit_model() on INLA nbinomial based objects", {
  temp.dir <- tempdir()
  dataset <- n2kanalysis:::test_data(missing = 0.2)
  this.analysis.date <- as.POSIXct("2015-01-01 12:13:14", tz = "UTC")
  this.scheme.id <- sha1(letters)
  this.species.group.id <- sha1(letters)
  this.location.group.id <- sha1(letters)
  this.model.type <- "inla nbinomial: A + B + C + D"
  this.formula <-
    "Count ~ A * (B + C) + C * D + f(E, model = 'iid')"
  this.first.imported.year <- 1990L
  this.last.imported.year <- 2015L
  this.last.analysed.year <- 2014L
  this.duration <- 1L
  lin.comb <- dataset %>%
    distinct_(~A) %>%
    model.matrix(object = ~A)
  rownames(lin.comb) <- seq_len(nrow(lin.comb))
  bad.lin.comb <- lin.comb[, -1]
  lin.comb.list <- as.list(as.data.frame(lin.comb))
  names(lin.comb.list[[1]]) <- seq_along(lin.comb.list[[1]])
  lin.comb.list2 <- list(E = diag(length(unique(dataset$E))))
  rownames(lin.comb.list2[[1]]) <- seq_along(unique(dataset$E))
  object <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = this.formula,
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    data = dataset
  )
  object.lc <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = this.formula,
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    data = dataset,
    lin.comb = lin.comb
  )
  object.lc.list <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = this.formula,
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    data = dataset,
    lin.comb = lin.comb.list
  )
  object.lc.list2 <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = this.formula,
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    data = dataset,
    lin.comb = lin.comb.list2
  )
  object.badlc <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = this.formula,
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    data = dataset,
    lin.comb = bad.lin.comb
  )
  object.imp <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = this.formula,
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    imputation.size = 10,
    data = dataset
  )
  object.fit <- fit_model(object)
  object.lc.fit <- fit_model(object.lc)
  object.lc.list.fit <- fit_model(object.lc.list)
  object.lc.list2.fit <- fit_model(object.lc.list2)
  object.badlc.fit <- fit_model(object.badlc)
  object.imp.fit <- fit_model(object.imp)
  cat(
    "\nobject.file <- \"", get_file_fingerprint(object), "\"\n",
    "object.lc.file <- \"", get_file_fingerprint(object.lc), "\"\n",
    "object.lc.list.file <- \"", get_file_fingerprint(object.lc.list), "\"\n",
    "object.lc.list2.file <- \"", get_file_fingerprint(object.lc.list2), "\"\n",
    "object.badlc.file <- \"", get_file_fingerprint(object.badlc), "\"\n",
    sep = ""
  )
  # 32-bit windows
  object.file <- "f1804a280983c87ae1e6e0ae1f4a25fd3a368d21"
  object.lc.file <- "f62d83dbbffcb6c5ca389c4aa382b73d6ea9278d"
  object.lc.list.file <- "61724622f28c1fc4a516a5e93d4efd47231d9d8e"
  object.lc.list2.file <- "64e43b3dd33b1c6a5f63fdbc0d3bf660a664c48f"
  object.badlc.file <- "cef68eb4b2dfca4bdc61ae7f491da41560b30367"

  it("returns the same file fingerprints on 32-bit and 64-bit", {
    expect_identical(object.file, get_file_fingerprint(object))
    expect_identical(object.lc.file, get_file_fingerprint(object.lc))
    expect_identical(object.lc.list.file, get_file_fingerprint(object.lc.list))
    expect_identical(
      object.lc.list2.file,
      get_file_fingerprint(object.lc.list2)
    )
    expect_identical(object.badlc.file, get_file_fingerprint(object.badlc))
  })
  it("doesn't alter the file fingerprint when fitting a model", {
    expect_identical(
      get_file_fingerprint(object),
      get_file_fingerprint(object.fit)
    )
    expect_identical(
      get_file_fingerprint(object.lc),
      get_file_fingerprint(object.lc.fit)
    )
  })
  it("returns valid objects", {
    expect_that(
      validObject(object.fit),
      is_true()
    )
    expect_that(
      validObject(object.lc.fit),
      is_true()
    )
  })
  it("works with objects saved in rds files", {
    analysis <- object
    filename <- store_model(analysis, base = temp.dir, project = "fit_model")
    expect_identical(status(filename)$Status, "new")
    fit_model(filename)
    filename <- gsub("new", "converged", filename)
    expect_identical(
      status(filename)$Status,
      "converged"
    )
    analysis <- object.lc
    filename <- store_model(analysis, base = temp.dir, project = "fit_model")
    expect_identical(status(filename)$Status, "new")
    fit_model(filename)
    filename <- gsub("new", "converged", filename)
    expect_identical(
      status(filename)$Status,
      "converged"
    )
  })

  it("doesn't refit converged models with the default status", {
    expect_identical(
      fit_model(object.fit),
      object.fit
    )
    expect_identical(
      fit_model(object.lc.fit),
      object.lc.fit
    )
  })
  it("returns an error when the linear combination is not valid", {
    expect_identical(
      status(object.badlc.fit),
      "error"
    )
  })

  # clean temp files
  file.remove(list.files(temp.dir, recursive = TRUE, full.names = TRUE))
})

test_that("fit_model() works on n2kInlaComparison", {
  this.scheme.id <- sha1(letters)
  this.species.group.id <- sha1(letters)
  this.location.group.id <- sha1(letters)
  this.analysis.date <- Sys.time()
  this.model.type <- "inla nbinomial: A * (B + C) + C:D"
  this.first.imported.year <- 1990L
  this.last.imported.year <- 2015L
  this.last.analysed.year <- 2014L
  this.duration <- 1L
  dataset <- n2kanalysis:::test_data()
  temp.dir <- tempdir()

  analysis <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = "Count ~ A",
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    data = dataset
  )
  p1 <- get_file_fingerprint(analysis)
  filename1 <- store_model(analysis, base = temp.dir, project = "fit_model")
  analysis <- n2k_inla_nbinomial(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    model.type = this.model.type,
    formula = "Count ~ A * B",
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    data = dataset
  )
  p2 <- get_file_fingerprint(analysis)
  filename2 <- store_model(analysis, base = temp.dir, project = "fit_model")

  analysis <- n2k_inla_comparison(
    scheme.id = this.scheme.id,
    species.group.id = this.species.group.id,
    location.group.id = this.location.group.id,
    formula = "~B", #nolint
    model.type = "inla comparison: A*B",
    first.imported.year = this.first.imported.year,
    last.imported.year = this.last.imported.year,
    analysis.date = this.analysis.date,
    parent = c(p1, p2),
    parent.status = status(temp.dir) %>%
      select_(
        ParentAnalysis = ~FileFingerprint,
        ParentStatus = ~Status,
        ParentStatusFingerprint = ~StatusFingerprint
      )
  )
  filename3 <- store_model(analysis, base = temp.dir, project = "fit_model")
  fit_model(filename3, verbose = FALSE)

  fit_model(filename1, verbose = FALSE)
  fit_model(filename3, verbose = FALSE)

  fit_model(filename2, verbose = FALSE)
  fit_model(filename3, verbose = FALSE)
  filename3 <- gsub("waiting", "converged", filename3)
  fit_model(filename3, verbose = FALSE)

  # clean temp files
  file.remove(list.files(temp.dir, recursive = TRUE, full.names = TRUE))
})