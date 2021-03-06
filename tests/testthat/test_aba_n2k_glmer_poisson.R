context("prepare a n2kGlmerPoisson object")
this.result.datasource.id <- sha1(sample(letters))
this.scheme.id <- sha1(sample(letters))
this.species.group.id <- sha1(sample(letters))
this.location.group.id <- sha1(sample(letters))
this.seed <- 4L
this.analysis.date <- Sys.time()
this.model.type <- "glmer poisson: period + herd"
this.formula <- "incidence ~ offset(log(size)) + period + (1|herd)"
weighted.model.type <- "weighted glmer poisson: period + herd"
this.first.imported.year <- 1990L
this.last.imported.year <- 2015L
this.last.analysed.year <- 2014L
this.duration <- 1L
data("cbpp", package = "lme4")
cbpp$DataFieldID <- sha1(letters)
cbpp$ObservationID <- seq_len(nrow(cbpp))
object <- n2k_glmer_poisson(
  result.datasource.id = this.result.datasource.id,
  scheme.id = this.scheme.id,
  species.group.id = this.species.group.id,
  location.group.id = this.location.group.id,
  model.type = this.model.type,
  formula = this.formula,
  first.imported.year = this.first.imported.year,
  last.imported.year = this.last.imported.year,
  analysis.date = this.analysis.date,
  data = cbpp
)
model.object <- lme4::glmer(
  incidence ~ offset(log(size)) + period + (1 | herd),
  data = object@Data,
  family = poisson
)
model.truth <- lme4::glmer(
  incidence ~ offset(log(size)) + period + (1 | herd),
  data = cbpp,
  family = poisson
)

describe("n2k_glmer_poisson", {
  it("adds the data as a data.frame", {
    expect_that(
      object@Data,
      is_identical_to(cbpp)
    )
    expect_that(
      coef(model.object),
      is_identical_to(coef(model.truth))
    )
  })
  it("uses 'new' as default status", {
    expect_that(
      object@AnalysisMetadata$Status,
      is_identical_to("new")
    )
  })
  it("requires a correct status", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        status = "junk"
      ),
      throws_error("Status must be one of the following")
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        status = NA_character_
      ),
      throws_error("Status must be one of the following")
    )
  })
  it("checks if the weight variable exists", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = weighted.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date
      ),
      throws_error("Variables missing in data: Weight")
    )
  })
  it("checks the model type", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = "junk",
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date
      ),
      throws_error("ModelType should be 'glmer poisson'")
    )
  })
  it("sets the correct parent", {
    expect_identical(
      nrow(
        n2k_glmer_poisson(
          data = cbpp,
          result.datasource.id = this.result.datasource.id,
          scheme.id = this.scheme.id,
          species.group.id = this.species.group.id,
          location.group.id = this.location.group.id,
          model.type = this.model.type,
          formula = this.formula,
          first.imported.year = this.first.imported.year,
          last.imported.year = this.last.imported.year,
          analysis.date = this.analysis.date,
          seed = this.seed
        )@AnalysisRelation
      ),
      0L
    )
    this.parent <- "12345"
    expect_identical(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        seed = this.seed,
        parent = this.parent
      )@AnalysisRelation$ParentAnalysis,
      this.parent
    )
    this.parent <- c("12345", "abc")
    expect_identical(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        seed = this.seed,
        parent = this.parent
      )@AnalysisRelation$ParentAnalysis,
      this.parent
    )
    expect_error(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        seed = this.seed,
        parent = 1234
      ),
      "dots\\$parent is neither character nor factor"
    )
  })
  it("sets the correct seed", {
    this.seed <- 12345L
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        seed = this.seed
      )@AnalysisMetadata$Seed,
      is_identical_to(this.seed)
    )
  })
  it("converts numeric seed, when possible", {
    this.seed <- 12345
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        seed = this.seed
      )@AnalysisMetadata$Seed,
      is_identical_to(as.integer(this.seed))
    )
    this.seed <- 12345L
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        scheme.id = this.scheme.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        seed = this.seed + 0.1
      ),
      throws_error("seed is not a count \\(a single positive integer\\)")
    )
  })
  it("sets a random seed when not provided", {
    expect_that(
      object@AnalysisMetadata$Seed,
      is_a("integer")
    )
  })

  it("sets the correct SchemeID", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$SchemeID,
      is_identical_to(this.scheme.id)
    )
  })

  it("sets the correct SpeciesGroupID", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        formula = this.formula,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$SpeciesGroupID,
      is_identical_to(this.species.group.id)
    )
  })

  it("sets the correct LocationGroupID", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$LocationGroupID,
      is_identical_to(this.location.group.id)
    )
  })

  it("sets the correct FirstImportedYear", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$FirstImportedYear,
      is_identical_to(this.first.imported.year)
    )
  })
  it("converts numeric first.imported.year, when possible", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = as.numeric(this.first.imported.year),
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$FirstImportedYear,
      is_identical_to(this.first.imported.year)
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year + 0.1,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error(
        "first.imported.year is not a count \\(a single positive integer\\)"
      )
    )
  })
  it("checks that FirstImportedYear is from the past", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = as.integer(format(Sys.time(), "%Y")) + 1,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("FirstImportedYear cannot exceed LastImportedYear")
    )
  })

  it("sets the correct LastImportedYear", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$LastImportedYear,
      is_identical_to(this.last.imported.year)
    )
  })
  it("converts numeric last.imported.year, when possible", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = as.numeric(this.last.imported.year),
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$LastImportedYear,
      is_identical_to(this.last.imported.year)
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year + 0.1,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error(
        "last.imported.year is not a count \\(a single positive integer\\)"
      )
    )
  })
  it("checks that LastImportedYear is from the past", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = as.integer(format(Sys.time(), "%Y")) + 1,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("LastImportedYear from the future.")
    )
  })
  it("checks that LastImportedYear is more recent than FirstImportedYear", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = 2000,
        last.imported.year = 1999,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("FirstImportedYear cannot exceed LastImportedYear")
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = as.integer(format(Sys.time(), "%Y")),
        last.imported.year = as.integer(format(Sys.time(), "%Y")),
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      is_a("n2kGlmerPoisson")
    )
  })

  it("sets the correct Duration", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = this.duration,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$Duration,
      is_identical_to(this.duration)
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$Duration,
      is_identical_to(this.last.imported.year - this.first.imported.year + 1L)
    )
  })
  it("converts numeric duration, when possible", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = as.numeric(this.duration),
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$Duration,
      is_identical_to(this.duration)
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = this.duration + 0.1,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("duration is not a count \\(a single positive integer\\)")
    )
  })
  it(
"checks that Duration is not outside the FirstImportYear - LastImportedYear
ranges", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = 1999,
        last.imported.year = 1999,
        duration = 2,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error(
"Duration longer than the interval from FirstImportedYear to LastImportedYear"
      )
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = 1999,
        last.imported.year = 1999,
        duration = 0,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error(
        "dots\\$duration is not a count \\(a single positive integer\\)"
      )
    )
  })

  it("sets the correct LastImportedYear", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = 1,
        last.analysed.year = this.last.analysed.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$LastAnalysedYear,
      is_identical_to(this.last.analysed.year)
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = 1,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$LastAnalysedYear,
      is_identical_to(this.last.imported.year)
    )
  })
  it("converts numeric last.imported.year, when possible", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = 1,
        last.analysed.year = as.numeric(this.last.analysed.year),
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      )@AnalysisMetadata$LastAnalysedYear,
      is_identical_to(this.last.analysed.year)
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = 1L,
        last.analysed.year = this.last.analysed.year + 0.1,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error(
        "last.analysed.year is not a count \\(a single positive integer\\)"
      )
    )
  })
  it("checks that LastAnalyseYear is within range", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        last.analysed.year = this.last.imported.year + 1,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("LastAnalysedYear cannot exceed LastImportedYear")
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        duration = this.duration,
        last.analysed.year = this.first.imported.year + this.duration - 2,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error(
"LastAnalysedYear smaller than FirstImportedYear \\+ Duration - 1. Window
outside imported range."
)
    )
  })

  it("checks if analysis date is from the past", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp,
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = Sys.time() + 24 * 60 * 60,
        scheme.id = this.scheme.id
      ),
      throws_error("AnalysisDate must be in the past")
    )
  })
  it("checks if all variables in formula are available in the data", {
    expect_that(
      n2k_glmer_poisson(
        data = cbpp[, c("herd", "period", "size")],
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("object@Data does not have .*name.*incidence")
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp[,
          c("herd", "period", "incidence", "DataFieldID", "ObservationID")
        ],
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("object@Data does not have .*name.*size")
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp[,
          c("herd", "size", "incidence", "DataFieldID", "ObservationID")
        ],
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("object@Data does not have .*name.*period")
    )
    expect_that(
      n2k_glmer_poisson(
        data = cbpp[,
          c("size", "period", "incidence", "DataFieldID", "ObservationID")
        ],
        result.datasource.id = this.result.datasource.id,
        species.group.id = this.species.group.id,
        location.group.id = this.location.group.id,
        model.type = this.model.type,
        formula = this.formula,
        first.imported.year = this.first.imported.year,
        last.imported.year = this.last.imported.year,
        analysis.date = this.analysis.date,
        scheme.id = this.scheme.id
      ),
      throws_error("object@Data does not have .*name.*herd")
    )
  })
})












describe("add a model to a n2kGlmerPoisson object", {
  object.model <- n2k_glmer_poisson(
    data = object, model.fit = model.object, status = "converged"
  )
  it("keeps the objects", {
    expect_that(
      object.model@Data,
      is_identical_to(cbpp)
    )
    expect_that(
      coef(object.model@Model),
      is_identical_to(coef(model.truth))
    )
    expect_that(
      object.model@Model,
      is_identical_to(model.object)
    )
    expect_that(
      object.model@AnalysisMetadata$Seed,
      is_identical_to(object@AnalysisMetadata$Seed)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        seed = 1
      )@AnalysisMetadata$Seed,
      is_identical_to(object@AnalysisMetadata$Seed)
    )
    expect_that(
      object.model@AnalysisMetadata$SchemeID,
      is_identical_to(object@AnalysisMetadata$SchemeID)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        scheme.id = sha1(LETTERS)
      )@AnalysisMetadata$SchemeID,
      is_identical_to(object@AnalysisMetadata$SchemeID)
    )
    expect_that(
      object.model@AnalysisMetadata$SpeciesGroupID,
      is_identical_to(object@AnalysisMetadata$SpeciesGroupID)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        species.group.id = sha1(LETTERS)
      )@AnalysisMetadata$SpeciesGroupID,
      is_identical_to(object@AnalysisMetadata$SpeciesGroupID)
    )
    expect_that(
      object.model@AnalysisMetadata$LocationGroupID,
      is_identical_to(object@AnalysisMetadata$LocationGroupID)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        location.group.id = sha1(LETTERS)
      )@AnalysisMetadata$LocationGroupID,
      is_identical_to(object@AnalysisMetadata$LocationGroupID)
    )
    expect_that(
      object.model@AnalysisMetadata$ModelType,
      is_identical_to(object@AnalysisMetadata$ModelType)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        model.type = 999
      )@AnalysisMetadata$ModelType,
      is_identical_to(object@AnalysisMetadata$ModelType)
    )
    expect_that(
      object.model@AnalysisMetadata$Covariate,
      is_identical_to(object@AnalysisMetadata$Covariate)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        covariate = 999
      )@AnalysisMetadata$Covariate,
      is_identical_to(object@AnalysisMetadata$Covariate)
    )
    expect_that(
      object.model@AnalysisMetadata$FirstImportedYear,
      is_identical_to(object@AnalysisMetadata$FirstImportedYear)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        first.imported.year = 3000
      )@AnalysisMetadata$FirstImportedYear,
      is_identical_to(object@AnalysisMetadata$FirstImportedYear)
    )
    expect_that(
      object.model@AnalysisMetadata$LastImportedYear,
      is_identical_to(object@AnalysisMetadata$LastImportedYear)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        last.imported.year = 3000
      )@AnalysisMetadata$LastImportedYear,
      is_identical_to(object@AnalysisMetadata$LastImportedYear)
    )
    expect_that(
      object.model@AnalysisMetadata$LastAnalysedYear,
      is_identical_to(object@AnalysisMetadata$LastAnalysedYear)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        last.analysed.year = 3000
      )@AnalysisMetadata$LastAnalysedYear,
      is_identical_to(object@AnalysisMetadata$LastAnalysedYear)
    )
    expect_that(
      object.model@AnalysisMetadata$Duration,
      is_identical_to(object@AnalysisMetadata$Duration)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        duration = 999
      )@AnalysisMetadata$Duration,
      is_identical_to(object@AnalysisMetadata$Duration)
    )
    expect_that(
      object.model@AnalysisMetadata$AnalysisDate,
      is_identical_to(object@AnalysisMetadata$AnalysisDate)
    )
    expect_that(
      n2k_glmer_poisson(
        data = object,
        model.fit = model.object,
        status = "converged",
        analysis.date = 999
      )@AnalysisMetadata$AnalysisDate,
      is_identical_to(object@AnalysisMetadata$AnalysisDate)
    )
  })
  it("stores the new status", {
    expect_that(
      object.model@AnalysisMetadata$Status,
      is_identical_to("converged")
    )
    expect_that(
      n2k_glmer_poisson(
        data = object, model.fit = model.object, status = "junk"
      ),
      throws_error("Status must be one of the following")
    )
  })
  model.binomial <- lme4::glmer(
    cbind(incidence, size - incidence) ~ period + (1 | herd),
    data = object@Data,
    family = binomial
  )
  it("checks if the model is a poisson model", {
    expect_that(
      n2k_glmer_poisson(
        data = object, model.fit = model.binomial, status = "converged"
      ),
      throws_error("The model must be from the poisson family")
    )
  })
})
