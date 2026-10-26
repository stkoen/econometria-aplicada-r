# Desde la raíz: Rscript --vanilla run_all.R [EE1 EE2 ...]
portfolio_root <- normalizePath(getwd(),winslash="/",mustWork=TRUE)
if(!file.exists("R/common.R")) stop("Ejecutar desde la raíz del portafolio.")
packages <- c("AER","vars","urca","readxl","ggplot2","lmtest","sandwich","plm","digest","jsonlite","dynlm","forecast")
missing <- packages[!vapply(packages,requireNamespace,logical(1),quietly=TRUE)]
if(length(missing)) stop("Faltan paquetes: ",paste(missing,collapse=", "),
                         ". Ejecutar scripts/install_dependencies.R.")
selected <- commandArgs(trailingOnly=TRUE)
if(!length(selected)) selected <- paste0("EE",1:6)
stopifnot(all(selected %in% paste0("EE",1:6)),!anyDuplicated(selected))
for(code in selected) {
  message("Ejecutando ",code)
  e <- new.env(parent=globalenv());e$portfolio_root <- portfolio_root
  e$out <- file.path(portfolio_root,"proyectos",code,"results")
  dir.create(file.path(e$out,"figures"),recursive=TRUE,showWarnings=FALSE)
  sys.source("R/common.R",envir=e)
  if(code=="EE3") {
    old <- getwd();setwd(file.path(portfolio_root,"proyectos","EE3"))
    tryCatch(sys.source("run.R",envir=e),finally=setwd(old))
  } else sys.source(file.path("proyectos",code,"analysis.R"),envir=e)
  capture.output(utils::sessionInfo(),file=file.path(e$out,"sessionInfo.txt"))
}
message("Análisis terminados. Ejecutar tests/check_all.R.")
