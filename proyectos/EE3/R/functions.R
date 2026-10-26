# Funciones de lectura, validación e inferencia del ejercicio.
get_airfare <- function() {
  url <- paste0(
    "https://raw.githubusercontent.com/JustinMShea/wooldridge/",
    "e95144d3d70e54c2afb4a6d3575f63fc60bfa6ec/data/airfare.RData"
  )
  expected_md5 <- "da5f3d5264aeb420b1d216279316bc7a"
  path <- file.path("data", "raw", "airfare.RData")
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(path)) {
    temp <- tempfile(tmpdir = dirname(path), fileext = ".RData")
    on.exit(unlink(temp), add = TRUE)
    utils::download.file(url, temp, mode = "wb", quiet = TRUE)
    stopifnot(unname(tools::md5sum(temp)) == expected_md5)
    if (!file.rename(temp, path)) stop("No se pudo guardar la base descargada.")
  }
  if (unname(tools::md5sum(path)) != expected_md5) {
    stop("La base no coincide con la revisión esperada; revisar data/raw.")
  }
  env <- new.env(parent = emptyenv())
  objects <- load(path, envir = env)
  if (!"airfare" %in% objects) stop("No se encontró el objeto airfare.")
  as.data.frame(env$airfare)
}

validate_airfare <- function(d) {
  cols <- c("id", "year", "fare", "bmktshr", "dist")
  stopifnot(all(cols %in% names(d)), nrow(d) == 4596L)
  stopifnot(!anyNA(d[cols]), all(is.finite(as.matrix(d[cols]))))
  stopifnot(all(d$fare > 0), all(d$dist > 0))
  stopifnot(all(d$bmktshr >= 0 & d$bmktshr <= 1))
  stopifnot(!anyDuplicated(d[c("id", "year")]))
  stopifnot(setequal(d$year, 1997:2000), length(unique(d$id)) == 1149L)
  stopifnot(all(table(d$id) == 4L))
  # Las variables de distancia deben ser exactamente invariantes dentro de ruta.
  stopifnot(all(vapply(split(d$dist, d$id), function(x) length(unique(x)) == 1L,
                       logical(1))))
  invisible(TRUE)
}

cluster_vcov <- function(model) {
  plm::vcovHC(model, method = "arellano", type = "HC1", cluster = "group")
}

tidy_cluster <- function(model, label) {
  V <- cluster_vcov(model)
  ct <- lmtest::coeftest(model, vcov. = V)
  critical <- stats::qt(0.975, df = stats::df.residual(model))
  data.frame(
    model = label, term = rownames(ct), estimate = ct[, 1],
    std_error = ct[, 2], statistic = ct[, 3], p_value = ct[, 4],
    lower95 = ct[, 1] - critical * ct[, 2],
    upper95 = ct[, 1] + critical * ct[, 2], row.names = NULL
  )
}

write_table <- function(x, name) {
  utils::write.csv(x, file.path("results", name), row.names = FALSE, na = "")
}

tidy_test <- function(test, label) {
  data.frame(test = label, statistic = unname(test$statistic),
             df = unname(test$parameter), p_value = test$p.value)
}
