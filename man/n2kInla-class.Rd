% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/n2kInla_class.R
\docType{class}
\name{n2kInla-class}
\alias{n2kInla-class}
\title{The n2kInla class}
\description{
It hold analysis data based on an INLA poisson model
}
\section{Slots}{

\describe{
\item{\code{Data}}{A \code{data.frame} with the data.}
\item{\code{LinearCombination}}{An optional matrix with the linear
combinations.}
\item{\code{ReplicateName}}{An optional list with names of replicates.}
\item{\code{Model}}{Either NULL or the resulting INLA model.}
\item{\code{Family}}{The family of the INLA model}
\item{\code{ImputationSize}}{The number of multiple imputations.
Defaults to \code{0}, indication no multiple imputation.}
\item{\code{Minimum}}{An optional string containing the name of the
variable in \code{Data} holding the minimal values for imputation.}
\item{\code{RawImputed}}{A \code{rawImputed} object with multiple
imputations.}
}
}

