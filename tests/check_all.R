root<-normalizePath(getwd(),winslash="/")
read_result<-function(code,name) read.csv(file.path(root,"proyectos",code,"results",name))
for(code in c("EE1","EE2","EE4","EE5","EE6")) {
  r<-read_result(code,"reproduccion_entrega.csv")
  stopifnot(all(r$matches),all(abs(r$difference)<=r$tolerance))
  stopifnot(file.exists(file.path("proyectos",code,"results","informe.md")))
}
# Referencias externas a la implementación: coeficientes y errores publicados.
iv<-read_result("EE1","comparacion_kids.csv")
stopifnot(abs(iv$std_error[iv$model=="MC2E"]-3.013)<.001,
          iv$lower95[iv$model=="MC2E"]<0,iv$upper95[iv$model=="MC2E"]>0)
relevance<-read_result("EE1","relevancia_instrumento.csv")
stopifnot(abs(relevance$statistic[2]-46.9)<.1)
# Contraste DiD en niveles contra el cálculo directo de las cuatro medias.
means<-read_result("EE2","promedios_grupo_periodo.csv")
mean_cell<-function(t,p) means$precio_uf[means$tratado==t & means$periodo==p]
manual<-(mean_cell(1,2)-mean_cell(1,1))-(mean_cell(0,2)-mean_cell(0,1))
att<-read_result("EE2","efectos_DiD.csv")
stopifnot(abs(manual-att$estimate[att$model=="nivel_sin_controles"])<1e-8)
# El bloque EE3 conserva sus comprobaciones independientes.
old<-getwd();setwd("proyectos/EE3")
tryCatch(source("tests/check_reproduction.R",local=new.env()),finally=setwd(old))
# Selección temporal comparable y pronósticos coherentes en niveles.
a<-read_result("EE4","seleccion_AR_muestra_comun.csv")
f<-read_result("EE4","pronosticos_revisados.csv")
b<-read_result("EE4","validacion_temporal_predicciones.csv")
stopifnot(length(unique(a$n_common))==1L,nrow(b)==24L,
 all(abs(exp(f$log_level)-f$level_median)<1e-8),
 all(f$lower95_level<f$level_median),all(f$upper95_level>f$level_median),
 all(f$level_mean_lognormal>=f$level_median))
# Contraste independiente entre dos interfaces de estimación, y cobertura
# efectiva del horizonte y de las siete preguntas recuperadas del EE4.
dyn<-read_result("EE4","verificacion_dynlm.csv")
fc<-read_result("EE4","comparacion_ar_forecast.csv")
ft<-read_result("EE4","contrastes_F_enunciado.csv")
annual<-read_result("EE4","crecimiento_interanual_serie_completa.csv")
stopifnot(nrow(dyn)==16L,all(dyn$max_abs_coef_difference<1e-10),
 all(abs(dyn$AIC_difference)<1e-8),nrow(fc)==4L,
 identical(fc$date,c("2025-09-01","2025-10-01","2025-11-01","2025-12-01")),
 all(fc$lower95_YW<fc$automatic_YW),all(fc$upper95_YW>fc$automatic_YW),
 all(fc$upper95_YW-fc$lower95_YW>.1),
 abs(ft$F[1]-53.28)<.02,nrow(ft)==3L,
 nrow(annual)==420L,sum(annual$predicted)==4L)
# La discrepancia de definición del shock se preserva y la muestra ADF es común.
audit<-read_result("EE5","auditoria_definicion_shock.csv")
adf<-read_result("EE5","seleccion_ADF_AIC_muestra_comun.csv")
stopifnot(audit$mismatches[audit$window_months==36]==0,
          audit$mismatches[audit$window_months==12]>0,
          all(vapply(split(adf$n,adf$series),function(x)length(unique(x))==1L,logical(1))))
# Detecta la confusión de shock/respuesta que afectaba a las figuras originales.
ir<-read_result("EE6","IRF_nueve_respuestas.csv")
fv<-read_result("EE6","FEVD.csv")
pair<-read_result("EE6","Granger_seis_direcciones_condicionales.csv")
stopifnot(nrow(ir)==81L,length(unique(paste(ir$shock,ir$response)))==9L,nrow(pair)==6L)
own<-subset(ir,horizon==0 & shock==response)
stopifnot(all(own$value>0),all(abs(aggregate(share~response+horizon,fv,sum)$share-1)<1e-10),
 all(read_result("EE6","estabilidad.csv")$stable))
stopifnot(all(abs(subset(ir,horizon==0 & response=="u" & shock!="u")$value)<1e-12))
message("OK: referencias originales de los seis ejercicios y comprobaciones metodológicas superadas.")
