options(repos=c(CRAN="https://cloud.r-project.org"))
p <- c("AER","vars","urca","readxl","ggplot2","lmtest","sandwich","plm","digest","jsonlite","dynlm","forecast")
m <- p[!vapply(p,requireNamespace,logical(1),quietly=TRUE)]
if(length(m)) install.packages(m)
message("Dependencias disponibles. renv.lock registra las versiones verificadas.")
