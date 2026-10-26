# Comprobaciones con referencias de la entrega original, no solo del código revisado.
effects <- read.csv("results/concentration_effects.csv")
comparison <- read.csv("results/reproduction_original.csv")
hausman <- read.csv("results/hausman_tests.csv")
ci <- read.csv("results/pooled_ci_comparison.csv")
theta <- read.csv("results/re_transformation.csv")
descriptive <- read.csv("results/descriptive_by_year.csv")
stopifnot(setequal(effects$model, c("MCO", "RE", "FE")))
stopifnot(all(effects$n == 4596), all(effects$routes == 1149))
stopifnot(all(comparison$matches), all(abs(comparison$difference) < 0.0001))
stopifnot(all(effects$std_error > 0), all(effects$exact_lower95 < effects$exact_pct),
          all(effects$exact_pct < effects$exact_upper95))
stopifnot(abs(hausman$p_value[1] - 0.04048) < 0.0001)
stopifnot(abs(ci$lower95[ci$inference == "Usual_MCO"] - 0.3012) < 0.0001,
          abs(ci$upper95[ci$inference == "Usual_MCO"] - 0.4191) < 0.0001,
          abs(ci$lower95[ci$inference == "HC1"] - 0.2978) < 0.0001,
          abs(ci$upper95[ci$inference == "HC1"] - 0.4225) < 0.0001)
stopifnot(abs(theta$theta - 0.8355) < 0.0001,
          all(descriptive$dist_min == 95), all(descriptive$dist_max == 2724))
stopifnot(all(file.exists(file.path("results/figures", c(
  "fare_by_year.png", "share_by_year.png", "model_comparison.png")))))
stopifnot(file.exists("results/report.md"))
message("OK: panel, modelos, resultados de referencia, inferencia y salidas comprobados.")
