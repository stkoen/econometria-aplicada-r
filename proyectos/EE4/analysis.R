d<-as.data.frame(readxl::read_excel(original_file("ipm_chile.xlsx")))
stopifnot(nrow(d)==416L,all(c("Fecha","IPM") %in% names(d)),!anyNA(d),all(d$IPM>0))
months<-c(ene=1,feb=2,mar=3,abr=4,may=5,jun=6,jul=7,ago=8,sep=9,oct=10,nov=11,dic=12)
parts<-strsplit(tolower(as.character(d$Fecha)),"-",fixed=TRUE)
date<-as.Date(vapply(parts,function(v){yr<-as.integer(v[2]);yr<-if(yr>=90)1900+yr else 2000+yr
 sprintf("%04d-%02d-01",yr,months[v[1]])},character(1)))
stopifnot(!anyNA(date),all(date==seq(as.Date("1991-01-01"),by="month",length.out=416)))
level<-as.numeric(d$IPM);ly<-log(level);g<-diff(ly)
make_ar<-function(z,p,start_common=NULL) {
  x<-data.frame(target=z)
  for(j in 1:p) x[[paste0("L",j)]]<-lag_vector(z,j)
  keep<-complete.cases(x)
  if(!is.null(start_common)) keep<-keep & seq_along(z)>start_common
  lm(target~.,data=x[keep,,drop=FALSE])
}
ar_path<-function(model,z,h=4) {
  p<-length(coef(model))-1L;b<-coef(model);series<-z;pred<-numeric(h)
  for(j in 1:h){pred[j]<-b[1]+sum(b[-1]*rev(tail(series,p)));series<-c(series,pred[j])}
  pred
}
fits<-lapply(1:8,function(p)make_ar(g,p,8));legacy<-lapply(1:8,function(p)make_ar(g,p))
# Pregunta 2: interfaz dynlm pedida por el curso. Se comprueba contra la
# construcción explícita de rezagos, tanto en ventana común como variable.
gts<-ts(g,start=c(1991,2),frequency=12)
dynfit<-function(pp,common=TRUE) {
  # dynlm evalúa merge.zoo dentro del entorno de la fórmula cuando se usa
  # mediante :: sin adjuntar paquetes a la sesión global.
  merge.zoo<-zoo::merge.zoo
  form<-as.formula(sprintf("gts ~ L(gts, 1:%d)",pp),env=environment())
  if(common) dynlm::dynlm(form,start=time(gts)[9]) else dynlm::dynlm(form)
}
dyn_common<-lapply(1:8,dynfit)
dyn_variable<-lapply(1:8,function(pp)dynfit(pp,FALSE))
dyn_check<-do.call(rbind,lapply(c("comun","variable"),function(window) {
  ff<-if(window=="comun")dyn_common else dyn_variable
  ll<-if(window=="comun")fits else legacy
  do.call(rbind,lapply(1:8,function(j)data.frame(window=window,p=j,n=nobs(ff[[j]]),
    AIC_dynlm=AIC(ff[[j]]),max_abs_coef_difference=max(abs(coef(ff[[j]])-coef(ll[[j]]))),
    AIC_difference=AIC(ff[[j]])-AIC(ll[[j]]))))
}))
stopifnot(all(dyn_check$max_abs_coef_difference<1e-10),all(abs(dyn_check$AIC_difference)<1e-8))
put(dyn_check,"verificacion_dynlm.csv")
selection<-data.frame(p=1:8,n_common=vapply(fits,nobs,numeric(1)),
 AIC_common=vapply(fits,AIC,numeric(1)),n_original=vapply(legacy,nobs,numeric(1)),
 AIC_original_variable_sample=vapply(legacy,AIC,numeric(1)))
put(selection,"seleccion_AR_muestra_comun.csv")
p<-selection$p[which.min(selection$AIC_common)];original_p<-selection$p[which.min(selection$AIC_original_variable_sample)]
model<-make_ar(g,p);put(coef_table(model,paste0("AR",p)),"coeficientes_AR.csv")
roots<-polyroot(c(1,-coef(model)[-1]));stable<-all(Mod(roots)>1)
put(data.frame(root_modulus=Mod(roots),outside_unit_circle=Mod(roots)>1),"raices_AR.csv")
f<-summary(model)$fstatistic
joint<-data.frame(F=unname(f[1]),df1=unname(f[2]),df2=unname(f[3]),p_value=pf(f[1],f[2],f[3],lower.tail=FALSE))
put(joint,"significancia_conjunta.csv")
# La pregunta 3 menciona seis rezagos aunque se seleccionan ocho. Se informa
# la prueba principal del modelo elegido y, separadamente, AR(6) y los seis
# primeros coeficientes dentro del AR(8); no se confunden las hipótesis.
m6<-make_ar(g,6);f6<-summary(m6)$fstatistic
restricted6<-lm(target~L7+L8,data=model.frame(make_ar(g,8)))
full8<-make_ar(g,8)
f6conditional<-((deviance(restricted6)-deviance(full8))/6)/(deviance(full8)/df.residual(full8))
joint_details<-rbind(
 data.frame(test=paste0("Todos los rezagos de AR(",p,")"),n=nobs(model),joint),
 data.frame(test="Todos los rezagos de AR(6)",n=nobs(m6),F=unname(f6[1]),df1=6,
  df2=df.residual(m6),p_value=pf(f6[1],6,df.residual(m6),lower.tail=FALSE)),
 data.frame(test="Rezagos 1 a 6 dentro de AR(8)",n=nobs(full8),F=f6conditional,df1=6,
  df2=df.residual(full8),p_value=pf(f6conditional,6,df.residual(full8),lower.tail=FALSE)))
put(joint_details,"contrastes_F_enunciado.csv")
pred<-ar_path(model,g,4);future_date<-seq(max(date),by="month",length.out=5)[-1]
log_pred<-tail(ly,1)+cumsum(pred)
# Propaga varianzas y covarianzas de innovaciones, con parámetros tratados como fijos.
phi<-unname(coef(model)[-1]);psi<-c(1,stats::ARMAtoMA(ar=phi,ma=numeric(),lag.max=3))
var_g<-summary(model)$sigma^2*cumsum(psi^2)
var_log_level<-summary(model)$sigma^2*cumsum(cumsum(psi)^2)
forecast<-data.frame(date=future_date,pred_dlog=pred,
 lower95_dlog=pred-qnorm(.975)*sqrt(var_g),upper95_dlog=pred+qnorm(.975)*sqrt(var_g),
 log_level=log_pred,level_median=exp(log_pred),
 level_mean_lognormal=exp(log_pred+var_log_level/2),
 lower95_level=exp(log_pred-qnorm(.975)*sqrt(var_log_level)),
 upper95_level=exp(log_pred+qnorm(.975)*sqrt(var_log_level)))
put(forecast,"pronosticos_revisados.csv")

# Reconstrucción independiente del procedimiento original: selección variable + ARIMA ML/CSS.
ml<-stats::arima(g,order=c(original_p,0,0),include.mean=TRUE)
mlpred<-predict(ml,n.ahead=4)
original_rebuilt<-data.frame(date=future_date,p_original=original_p,
 pred_dlog=as.numeric(mlpred$pred),log_level=tail(ly,1)+cumsum(as.numeric(mlpred$pred)))
original_rebuilt$level_median<-exp(original_rebuilt$log_level)
put(original_rebuilt,"reconstruccion_procedimiento_original.csv")
auto<-stats::ar(g,order.max=8,aic=TRUE)
# Conserva la serie en el objeto para que forecast no deba buscar el símbolo
# g en una sesión global; el portafolio ejecuta cada bloque en un entorno propio.
auto$x<-gts
ap<-stats::predict(auto,n.ahead=4)
put(data.frame(date=future_date,order=auto$order,pred_dlog=as.numeric(ap$pred)),"comparacion_Yule_Walker.csv")
auto_forecast<-forecast::forecast(auto,h=4,level=95)
auto_comparison<-data.frame(date=future_date,manual_MCO=pred,
 automatic_YW=as.numeric(auto_forecast$mean),lower95_YW=as.numeric(auto_forecast$lower[,1]),
 upper95_YW=as.numeric(auto_forecast$upper[,1]),selected_order=auto$order)
auto_comparison$difference_YW_minus_MCO<-auto_comparison$automatic_YW-auto_comparison$manual_MCO
stopifnot(max(abs(auto_comparison$automatic_YW-as.numeric(ap$pred)))<1e-12,
 identical(as.numeric(auto_forecast$level),95))
put(auto_comparison,"comparacion_ar_forecast.csv")
put(data.frame(p=0:8,AIC_relative_to_minimum=as.numeric(auto$aic)),"seleccion_automatica_Yule_Walker.csv")

# Validación temporal: 24 predicciones un paso, sin selección con datos futuros.
N<-length(level);origins<-(N-24):(N-1)
bt<-do.call(rbind,lapply(origins,function(t){
  z<-diff(ly[1:t]);candidates<-lapply(1:8,function(p)make_ar(z,p,8))
  pp<-which.min(vapply(candidates,AIC,numeric(1)));m<-make_ar(z,pp)
  pg<-ar_path(m,z,1)
  data.frame(date=date[t+1],actual=level[t+1],selected_p=pp,
   AR=exp(ly[t]+pg),Sin_cambio=level[t],Estacional_12=level[t+1-12])
}))
put(bt,"validacion_temporal_predicciones.csv")
metrics<-do.call(rbind,lapply(c("AR","Sin_cambio","Estacional_12"),function(v){
 err<-bt[[v]]-bt$actual;data.frame(model=v,n=length(err),MAE=mean(abs(err)),RMSE=sqrt(mean(err^2)))}))
put(metrics,"validacion_temporal_metricas.csv")
extended<-c(ly,log_pred);extended_date<-c(date,future_date)
yoy<-c(rep(NA_real_,12),extended[-(1:12)]-head(extended,-12))
idx2025<-format(extended_date,"%Y")=="2025"
annual<-data.frame(measure=c("Promedio mensual de variaciones interanuales log 2025",
 "Diciembre 2025 versus diciembre 2024 (%)","Promedio índice 2025 versus promedio 2024 (%)"),
 value=c(mean(yoy[idx2025]),100*expm1(tail(yoy,1)),
 100*(mean(exp(extended[idx2025]))/mean(level[format(date,"%Y")=="2024"])-1)))
put(annual,"tres_medidas_de_crecimiento.csv")
put(data.frame(date=extended_date,log_level=extended,
 growth12_log=yoy,growth12_exact_percent=100*expm1(yoy),
 predicted=extended_date>max(date)),"crecimiento_interanual_serie_completa.csv")
descriptive<-do.call(rbind,lapply(list(IPM=level,log_IPM=ly,dlog_IPM=g),function(x)
 data.frame(n=length(x),mean=mean(x),sd=sd(x),min=min(x),max=max(x))))
descriptive$variable<-rownames(descriptive);rownames(descriptive)<-NULL
descriptive<-descriptive[,c("variable","n","mean","sd","min","max")]
put(descriptive,"descriptivos.csv")
repro<-data.frame(statistic="IPM diciembre 2025 por procedimiento original",reference=104.28,
 reproduced=tail(original_rebuilt$level_median,1),tolerance=.02)
repro$difference<-repro$reproduced-repro$reference;repro$matches<-abs(repro$difference)<=repro$tolerance
put(repro,"reproduccion_entrega.csv")
transcription<-data.frame(date=future_date,reported_log=c(4.609,4.640,4.637,4.647),
 reported_level=c(100,104.1,103,104.3))
transcription$exp_reported_log<-exp(transcription$reported_log)
transcription$difference<-transcription$reported_level-transcription$exp_reported_log
put(transcription,"auditoria_tabla_original.csv")
plot_data<-data.frame(date=date,level=level)
series_plot<-rbind(data.frame(date=date,value=ly,series="Logaritmo del IPM"),
 data.frame(date=date[-1],value=g,series="Variación mensual del logaritmo"))
save_plot(ggplot2::ggplot(series_plot,ggplot2::aes(date,value))+
 ggplot2::geom_line(colour="#173F5F",linewidth=.35)+
 ggplot2::facet_wrap(~series,ncol=1,scales="free_y")+
 ggplot2::labs(title="IPM de Chile: nivel logarítmico y crecimiento mensual",x=NULL,y=NULL)+
 theme_portfolio(),"series_log_y_diferencia.png",height=6)
save_plot(ggplot2::ggplot(subset(plot_data,date>=as.Date("2022-01-01")),ggplot2::aes(date,level))+
 ggplot2::geom_line(colour="#173F5F")+
 ggplot2::geom_ribbon(data=forecast,ggplot2::aes(x=date,ymin=lower95_level,ymax=upper95_level),
  inherit.aes=FALSE,fill="#208070",alpha=.15)+
 ggplot2::geom_line(data=forecast,ggplot2::aes(date,level_median),colour="#208070",linewidth=.9)+
 ggplot2::geom_point(data=forecast,ggplot2::aes(date,level_median),colour="#208070")+
 ggplot2::labs(title="IPM: pronóstico a septiembre–diciembre de 2025",
 subtitle=paste0("AR(",p,") revisado; intervalos predictivos condicionales 95%"),
 x=NULL,y="Índice",caption="Se usan exclusivamente datos disponibles hasta agosto de 2025.")+theme_portfolio(),"pronostico_IPM.png")
save_plot(ggplot2::ggplot(metrics,ggplot2::aes(reorder(model,RMSE),RMSE))+
 ggplot2::geom_col(fill="#173F5F")+ggplot2::labs(title="Comparación fuera de muestra",
 subtitle="24 pronósticos mensuales un paso; menor RMSE es mejor",x="Modelo",y="RMSE del índice")+theme_portfolio(),"validacion_temporal.png")
report(c("# EE4: pronóstico del IPM de Chile","",
 "Khoen San Martín. Versión revisada para portafolio; entrega académica original de octubre de 2025.","",
 "Base original de 416 meses, enero de 1991 a agosto de 2025. Las fechas se leen y verifican; no se asignan periodos sin comprobar la columna Fecha. Se pronostican septiembre–diciembre de 2025 desde ese corte histórico.","",
 "## Base, descriptivos y pregunta 1: patrones temporales","",md_table(descriptive),
 "Se define lipm como el logaritmo del índice y dlog como su primera diferencia. El nivel logarítmico muestra variaciones de largo plazo y la diferencia oscila alrededor de una media más estable, con movimientos estacionales y episodios de volatilidad. Un gráfico no demuestra estacionariedad ni identifica por sí solo las causas de las caídas.","",
 "![Series](figures/series_log_y_diferencia.png)","",
 "## Pregunta 2: AR(1)–AR(8) y selección corregida","",md_table(selection),
 "Los ocho modelos se estiman también mediante dynlm, como pide el enunciado, y AIC. verificacion_dynlm.csv comprueba la coincidencia de coeficientes y AIC con la construcción explícita de rezagos. La ventana común evita comparar criterios de muestras diferentes; la tabla mantiene el cálculo de muestras variables de la entrega.","",
 sprintf("Con ventana común se selecciona AR(%d). El procedimiento de muestras variables del script original selecciona AR(%d). Un menor AIC no implica que cada rezago incluido sea individualmente significativo.",p,original_p),"",
 "Se usa MCO condicional tanto para selección como para la estimación revisada y su pronóstico. La reconstrucción original se mantiene separada porque reestima mediante arima después de seleccionar por MCO. El modelo automático ar usa por defecto Yule–Walker, una tercera forma de estimar; no se confunden diferencias numéricas entre métodos con errores.","",
 "## Pregunta 3: prueba F de significancia conjunta","",md_table(joint_details),
 "El contraste F habitual tiene como nula que todos los coeficientes de los rezagos evaluados son cero; la alternativa es que al menos uno sea distinto de cero. La redacción del enunciado invierte esa nula y menciona seis rezagos aun cuando el orden seleccionado puede ser ocho. Por eso se identifica el contraste principal del modelo elegido y se muestran las dos lecturas de la referencia a seis rezagos. Son pruebas convencionales condicionales al orden seleccionado: requieren los supuestos del modelo y no ajustan por selección previa mediante AIC. Rechazar no demuestra que todos los rezagos sean individualmente significativos ni garantiza precisión fuera de muestra.","",
 "## Preguntas 4 y 5: pronósticos de crecimiento y nivel","",md_table(forecast),
 "Se distinguen mediana transformada y media bajo supuesto lognormal. Exponenciar el pronóstico logarítmico no produce automáticamente la media aritmética. Los intervalos predictivos propagan las innovaciones, incluidas las covarianzas al acumular crecimientos, y tratan los parámetros estimados como fijos.","",
 "![Pronóstico](figures/pronostico_IPM.png)","",
 "## Comprobación temporal","",md_table(metrics),
 "En cada uno de los 24 orígenes finales se selecciona y estima usando solo información pasada. Se compara contra persistencia y contra índice del mismo mes del año anterior. No se elige el modelo con estos errores y se presenta luego la misma ventana como prueba independiente; los resultados describen esta evaluación histórica y no garantizan rendimiento futuro.","",
 "![Evaluación](figures/validacion_temporal.png)","",
 "La serie no fue desestacionalizada en la entrega y los candidatos llegan a ocho rezagos. El contraste con una referencia estacional a 12 meses es relevante. Una ampliación SARIMA o con dummies mensuales requiere evaluación temporal adicional; no se atribuye robustez general al AR por su significancia dentro de muestra.","",
 "## Pregunta 6: crecimiento interanual y promedio de 2025","",md_table(annual),
 "El promedio de tasas interanuales mensuales, la variación diciembre/diciembre y la variación de promedios anuales no son la misma medida. Los valores de 2025 combinan ocho meses observados y cuatro pronosticados.","",
 "La primera fila responde a la pregunta: media de las doce diferencias logarítmicas interanuales de 2025. Multiplicarla por 100 da una aproximación porcentual. crecimiento_interanual_serie_completa.csv contiene la serie completa y distingue los meses predichos.","",
 "## Pregunta 7: comparación con ar y forecast","",md_table(auto_comparison),
 "Se ejecutan ar con order.max=8 y selección AIC, y forecast con h=4 y level=95. El ejemplo del enunciado incluye un punto sintáctico sobrante, usa tres pasos y deja order.max=12 como ejemplo: se adapta al horizonte de cuatro meses solicitado. El AIC relativo de ar se guarda por separado; incluye AR(0) y no es el AIC absoluto de las regresiones dynlm. ar utiliza Yule–Walker por defecto y su selección y estimación no son idénticas a MCO. La cercanía de pronósticos se evalúa en la tabla, sin exigir igualdad entre estimadores.","",
 "## Entrega original","",md_table(repro),
 "Se documentan por separado discrepancias de transcripción entre logaritmos y niveles. Se contrastaron las siete preguntas con el enunciado del IPM y las instrucciones generales. La evaluación temporal y la distinción entre media y mediana son ampliaciones de portafolio.","",
 sprintf("Estabilidad del AR revisado: %s, comprobada con raíces fuera del círculo unidad.",stable),"",
 "## Conclusión y reflexión","",
 sprintf("El AR(%d) resume dependencia temporal del crecimiento y entrega un índice de diciembre cercano a %.2f al exponenciar el pronóstico logarítmico. La evaluación histórica de 24 meses permite comparar su error con referencias simples. El promedio de tasas interanuales de 2025 no debe presentarse como crecimiento diciembre/diciembre. La principal lección es mantener comparables las muestras y los estimadores, precisar la hipótesis F y distinguir evidencia dentro y fuera de muestra.",p,tail(forecast$level_median,1)),"",
 "Fuentes: base y enunciado de Mauricio Tejada, UDP, Econometría II 2025-S2. Código reproducible en ../analysis.R; trazabilidad y asistencia declaradas en el README general."
))
