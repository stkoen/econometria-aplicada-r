options(repos = c(CRAN = "https://cloud.r-project.org"))
needed <- c("ggplot2", "lmtest", "plm", "sandwich")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing)
message("Dependencias disponibles. Para fijar versiones, usar renv.lock.")
