# Ejecutar desde la raíz: Rscript --vanilla run.R
options(stringsAsFactors = FALSE, repos = c(CRAN = "https://cloud.r-project.org"))
needed <- c("ggplot2", "lmtest", "plm", "sandwich")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Instalar dependencias con: Rscript scripts/install_dependencies.R")
if (!file.exists("R/functions.R")) stop("Ejecutar desde la raíz del proyecto.")
source("R/functions.R")
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)

d <- get_airfare()
validate_airfare(d)
d <- d[order(d$id, d$year), ]
d$log_dist <- log(d$dist)
d$log_dist2 <- d$log_dist^2
d$year_1998 <- as.integer(d$year == 1998)
d$year_1999 <- as.integer(d$year == 1999)
d$year_2000 <- as.integer(d$year == 2000)
pdata <- plm::pdata.frame(d, index = c("id", "year"))
# Indicadores explícitos equivalentes a factor(year), con 1997 como referencia.
form <- log(fare) ~ bmktshr + log_dist + log_dist2 + year_1998 + year_1999 + year_2000

models <- list(
  MCO = plm::plm(form, data = pdata, model = "pooling"),
  RE = plm::plm(form, data = pdata, model = "random", random.method = "swar"),
  FE = plm::plm(form, data = pdata, model = "within", effect = "individual")
)
stopifnot(all(vapply(models, stats::nobs, numeric(1)) == nrow(d)))
stopifnot(!any(c("log_dist", "log_dist2") %in% names(stats::coef(models$FE))))

coefs <- do.call(rbind, Map(tidy_cluster, models, names(models)))
rownames(coefs) <- NULL
write_table(coefs, "coefficients_cluster.csv")
effects <- coefs[coefs$term == "bmktshr", ]
effects$n <- nrow(d)
effects$routes <- length(unique(d$id))
effects$delta_bmktshr <- 0.10
effects$approx_pct <- 100 * effects$estimate * effects$delta_bmktshr
effects$exact_pct <- 100 * expm1(effects$estimate * effects$delta_bmktshr)
effects$exact_lower95 <- 100 * expm1(effects$lower95 * effects$delta_bmktshr)
effects$exact_upper95 <- 100 * expm1(effects$upper95 * effects$delta_bmktshr)
write_table(effects, "concentration_effects.csv")

# Pregunta 3: comparación explícita de inferencia usual, HC1 y agrupada.
pooled_lm <- stats::lm(form, data = d)
covariances <- list(
  Usual_MCO = stats::vcov(pooled_lm),
  HC1 = sandwich::vcovHC(pooled_lm, type = "HC1"),
  Agrupada_ruta = cluster_vcov(models$MCO)
)
ci_comparison <- do.call(rbind, lapply(names(covariances), function(label) {
  beta <- unname(stats::coef(pooled_lm)["bmktshr"])
  se <- sqrt(covariances[[label]]["bmktshr", "bmktshr"])
  critical <- stats::qt(0.975, stats::df.residual(pooled_lm))
  data.frame(inference = label, estimate = beta, std_error = se,
             lower95 = beta - critical * se, upper95 = beta + critical * se)
}))
rownames(ci_comparison) <- NULL
write_table(ci_comparison, "pooled_ci_comparison.csv")
re_components <- data.frame(theta = unname(models$RE$ercomp$theta),
                            routes = length(unique(d$id)), periods = 4L)
write_table(re_components, "re_transformation.csv")

descriptive <- do.call(rbind, lapply(split(d, d$year), function(x) {
  data.frame(year = unique(x$year), n = nrow(x),
             fare_min = min(x$fare), fare_mean = mean(x$fare), fare_max = max(x$fare),
             share_min = min(x$bmktshr), share_mean = mean(x$bmktshr),
             share_max = max(x$bmktshr), dist_min = min(x$dist),
             dist_mean = mean(x$dist), dist_max = max(x$dist))
}))
rownames(descriptive) <- NULL
write_table(descriptive, "descriptive_by_year.csv")

haus_classic <- plm::phtest(models$FE, models$RE)
hausman <- tidy_test(haus_classic, "Hausman clasico")
write_table(hausman, "hausman_tests.csv")

# Efecto sobre log(fare) respecto a log(dist): una elasticidad parcial.
b <- stats::coef(models$MCO)
V <- cluster_vcov(models$MCO)
log_minimum <- -b["log_dist"] / (2 * b["log_dist2"])
distance_minimum <- exp(log_minimum)
distances <- as.numeric(stats::quantile(d$dist, c(0.1, 0.5, 0.9)))
elasticity <- b["log_dist"] + 2 * b["log_dist2"] * log(distances)
write_table(data.frame(distance_miles = distances, elasticity = elasticity),
            "distance_elasticities.csv")
write_table(data.frame(minimum_miles = unname(distance_minimum),
                       sample_min = min(d$dist), sample_max = max(d$dist),
                       in_sample = distance_minimum >= min(d$dist) &
                         distance_minimum <= max(d$dist)), "distance_minimum.csv")

# Auditoría contra números publicados en la entrega de 2025, con redondeo explícito.
reference <- data.frame(model = c("MCO", "RE", "FE"),
                        reference_beta = c(0.3601, 0.2090, 0.1689))
reproduction <- merge(reference, effects[c("model", "estimate")], by = "model")
reproduction$difference <- reproduction$estimate - reproduction$reference_beta
reproduction$tolerance <- 0.0001
reproduction$matches <- abs(reproduction$difference) <= reproduction$tolerance
write_table(reproduction, "reproduction_original.csv")
stopifnot(all(reproduction$matches))
stopifnot(abs(unname(haus_classic$statistic) - 9.9967) < 0.001,
          abs(haus_classic$p.value - 0.04048) < 0.0001)

theme <- ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank(),
                 plot.title = ggplot2::element_text(face = "bold"))
save_plot <- function(plot, file, width = 7.4, height = 4.4) {
  ggplot2::ggsave(file.path("results/figures", file), plot,
                 width = width, height = height, dpi = 180, bg = "white")
}
save_plot(ggplot2::ggplot(descriptive, ggplot2::aes(year, fare_mean)) +
            ggplot2::geom_line(colour = "#173F5F", linewidth = 0.9) +
            ggplot2::geom_point(colour = "#173F5F", size = 2.5) +
            ggplot2::scale_x_continuous(breaks = 1997:2000) +
            ggplot2::labs(title = "Tarifa media por año", x = "Año",
                           y = "Tarifa de ida (dólares nominales)",
                           caption = "1.149 rutas observadas en cada año. Fuente: airfare / Wooldridge.") + theme,
          "fare_by_year.png")
save_plot(ggplot2::ggplot(descriptive, ggplot2::aes(year, share_mean)) +
            ggplot2::geom_line(colour = "#208070", linewidth = 0.9) +
            ggplot2::geom_point(colour = "#208070", size = 2.5) +
            ggplot2::scale_x_continuous(breaks = 1997:2000) +
            ggplot2::labs(title = "Participación media de la aerolínea líder", x = "Año",
                           y = "Fracción de mercado", caption = "Indicador de liderazgo; no equivale al HHI.") + theme,
          "share_by_year.png")
effects$model <- factor(effects$model, levels = c("MCO", "RE", "FE"))
save_plot(ggplot2::ggplot(effects, ggplot2::aes(model, exact_pct)) +
            ggplot2::geom_hline(yintercept = 0, colour = "grey70", linetype = 2) +
            ggplot2::geom_errorbar(ggplot2::aes(ymin = exact_lower95, ymax = exact_upper95),
                                   width = 0.12, colour = "#173F5F") +
            ggplot2::geom_point(size = 3, colour = "#208070") +
            ggplot2::labs(title = "Asociación entre concentración y tarifa",
                           subtitle = "Aumento de 10 puntos porcentuales en la participación de la líder",
                           x = "Modelo", y = "Variación porcentual de tarifa",
                           caption = "IC 95% con errores agrupados por ruta. No identifica por sí solo un efecto causal.") + theme,
          "model_comparison.png")

source("R/report.R")
write_report(effects, hausman, reproduction, unname(distance_minimum),
             ci_comparison, re_components)
capture.output(utils::sessionInfo(), file = "results/sessionInfo.txt")
message("Reproducción terminada. Revisar results/ y ejecutar tests/check_reproduction.R.")
