#######################################################################
# stream -  Infrastructure for Data Stream Mining
# Copyright (C) 2013 Michael Hahsler, Matthew Bolanos, John Forrest 
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

DSC_CluStream <- function(
  m=100,
  horizon=1000, 
  t=2,
  k=NULL
) {
  
  ### Java code does parameter checking
  paramList <- list(
    h = as.integer(horizon),
    m = as.integer(m),
    t = t
    )
  
  # converting the param list to a cli string to use in java
  cliParams <- convert_params(paramList)
  
  # initializing the clusterer
#  clusterer <- .jnew("moa/clusterers/clustream/Clustream")
  clusterer <- .jnew("moa/clusterers/clustream/WithKmeans")
  options <- .jcall(clusterer, "Lmoa/options/Options;", "getOptions")
  .jcall(options, "V", "setViaCLIString", cliParams)
  .jcall(clusterer, "V", "prepareForUse")
  
  macro <- new.env()
  macro$newdata <- FALSE
  if(!is.null(k)) macro$macro <-DSC_Kmeans(k=k, weighted=TRUE, nstart=5) 
  
  # initializing the R object
  structure(
    list(
      description = "CluStream",
      options = cliParams,
      javaObj = clusterer,
      macro = macro
    ),
    class = c("DSC_CluStream","DSC_Micro","DSC_MOA","DSC")
  )
}



get_macroclusters.DSC_CluStream <- function(x, ...) {
  if(is.null(x$macro$macro)) stop("No k_macro set!")
  .update_reclustering(x)
 
  get_centers(x$macro$macro, type="macro")
}

get_macroweights.DSC_CluStream <- function(x, ...) {
  if(is.null(x$macro$macro)) stop("No k_macro set!")
  .update_reclustering(x)
  
  get_weights(x$macro$macro, type="macro")
}

microToMacro.DSC_CluStream <- function(x, micro=NULL) {
  if(is.null(x$macro$macro)) stop("No k set!")
  .update_reclustering(x)
  
  microToMacro(x$macro$macro, micro)  
}