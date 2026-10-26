d <- public_data("labsup")
stopifnot(nrow(d)==31857L,!anyNA(d[c("hours","kids","nonmomi","educ","age","black","hispan","samesex")]))
ols <- stats::lm(hours~kids+nonmomi+educ+age+I(age^2)+black+hispan,data=d)
first <- stats::lm(kids~samesex+nonmomi+educ+age+I(age^2)+black+hispan,data=d)
iv <- AER::ivreg(hours~kids+nonmomi+educ+age+I(age^2)+black+hispan |
                  samesex+nonmomi+educ+age+I(age^2)+black+hispan,data=d)
conventional <- rbind(coef_table(ols,"MCO"),coef_table(iv,"MC2E"),coef_table(first,"Primera etapa"))
# HC1 de MC2E con matrices n x k; no se construye una matriz hat n x n.
xp<-model.matrix(iv,component="projected");B<-solve(crossprod(xp))
V_iv_HC1<-nrow(xp)/df.residual(iv)*B%*%crossprod(xp*as.numeric(residuals(iv)))%*%B
robust <- rbind(coef_table(ols,"MCO",sandwich::vcovHC(ols,type="HC1")),
                coef_table(iv,"MC2E",V_iv_HC1))
put(conventional,"coeficientes_convencionales.csv");put(robust,"coeficientes_HC1.csv")
comparison <- conventional[conventional$term=="kids",];put(comparison,"comparacion_kids.csv")
f <- summary(first)$fstatistic;t <- summary(first)$coefficients["samesex","t value"]
relevance <- data.frame(contrast=c("F global primera etapa","F instrumento excluido"),
  statistic=c(unname(f[1]),t^2),df1=c(unname(f[2]),1L),df2=c(unname(f[3]),df.residual(first)))
relevance$p_value <- stats::pf(relevance$statistic,relevance$df1,relevance$df2,lower.tail=FALSE)
put(relevance,"relevancia_instrumento.csv")
# Wu–Hausman por función de control, evitando matrices de proyección n x n.
d$vhat<-residuals(first)
aug<-lm(hours~kids+nonmomi+educ+age+I(age^2)+black+hispan+vhat,data=d)
dt<-summary(aug)$coefficients["vhat","t value"]
diagnostics<-data.frame(test="Wu-Hausman por funcion de control",statistic=unname(dt^2),
 df1=1L,df2=df.residual(aug),p_value=pf(dt^2,1,df.residual(aug),lower.tail=FALSE))
put(diagnostics,"diagnosticos_MC2E.csv")
desc <- do.call(rbind,lapply(c("kids","hours","samesex","multi2nd"),function(v)
  data.frame(variable=v,n=length(d[[v]]),mean=mean(d[[v]]),sd=sd(d[[v]]),min=min(d[[v]]),max=max(d[[v]]))))
put(desc,"descriptivos.csv")
message("EE1: estimaciones, diagnósticos y descriptivos calculados")
freq <- do.call(rbind,lapply(c("samesex","multi2nd"),function(v){
  tab<-table(d[[v]]);data.frame(variable=v,value=names(tab),count=as.integer(tab),proportion=as.numeric(tab)/sum(tab))}))
put(freq,"frecuencias.csv")
repro <- data.frame(model=c("MCO","MC2E"),reference=c(-2.326,-4.879),
                    reproduced=c(coef(ols)["kids"],coef(iv)["kids"]),tolerance=.001)
repro$difference<-repro$reproduced-repro$reference;repro$matches<-abs(repro$difference)<=repro$tolerance
put(repro,"reproduccion_entrega.csv");stopifnot(all(repro$matches))
save_plot(ggplot2::ggplot(comparison,ggplot2::aes(model,estimate))+
  ggplot2::geom_hline(yintercept=0,linetype=2,colour="grey60")+
  ggplot2::geom_errorbar(ggplot2::aes(ymin=lower95,ymax=upper95),width=.12,colour="#173F5F")+
  ggplot2::geom_point(size=3,colour="#208070")+
  ggplot2::labs(title="Fertilidad y horas trabajadas",subtitle="Coeficiente de un hijo adicional; IC 95% convencionales",
                 x="Modelo",y="Horas semanales",caption="MC2E no rechaza coeficiente cero al 5%.")+theme_portfolio(),"comparacion_modelos.png")
hist_data<-rbind(data.frame(value=d$kids,variable="Número de hijos"),data.frame(value=d$hours,variable="Horas semanales"))
save_plot(ggplot2::ggplot(hist_data,ggplot2::aes(value))+
  ggplot2::geom_histogram(bins=30,fill="#173F5F",colour="white")+
  ggplot2::facet_wrap(~variable,scales="free")+
  ggplot2::labs(title="Distribuciones de la muestra",x=NULL,y="Frecuencia")+theme_portfolio(),"distribuciones.png")
report(c("# EE1: fertilidad y oferta laboral femenina","",
  "Datos públicos labsup: 31.857 observaciones. La unidad de análisis es una mujer de la muestra; no se modela un panel.","",
  "## Estimaciones originales reproducidas","",md_table(comparison[,c("model","estimate","std_error","p_value","lower95","upper95")]),
  "`nonmomi` mide ingresos del hogar distintos de los de la madre, en miles de dólares. Se corrige la etiqueta errónea de inmigración de la entrega; se conserva la misma variable numérica.","",
  "![Comparación](figures/comparacion_modelos.png)","",
  "## Relevancia e interpretación","",md_table(relevance),
  "El F global incluye todos los regresores de la primera etapa. El F del instrumento excluido evalúa samesex condicional en los controles y es el contraste pertinente de relevancia. Un F elevado no verifica exclusión ni independencia respecto del error estructural.","",
  "MCO estima una asociación negativa y precisa. MC2E entrega un coeficiente más negativo, pero su intervalo incluye cero. La diferencia entre estimadores no demuestra por sí sola el sentido del sesgo ni un efecto negativo causal confirmado.","",
  "Se calcula Wu–Hausman por función de control. Hay un instrumento excluido para una variable endógena: la ecuación está exactamente identificada y no existe un contraste de sobreidentificación informativo que pruebe la exclusión.","",
  "La interpretación causal de MC2E exige relevancia, exogeneidad y exclusión del instrumento, además de los supuestos de la especificación. Que el sexo de los hijos tenga un componente aleatorio no descarta un efecto directo de su composición sobre la oferta laboral. Con efectos heterogéneos y fertilidad discreta, el estimando puede depender de los márgenes modificados por el instrumento; no se presenta como efecto universal de la maternidad.","",
  "El modelo usa kids y hours, como la ecuación y la estimación instrumental del enunciado. La referencia de una pregunta a morekids y weeksm1 no cambia silenciosamente la especificación.","",
  "## Correspondencia con el curso","",
  "Se cubren descriptivos, MCO, discusión de endogeneidad, instrumento, primera etapa, MC2E y conclusiones. Los errores HC1 se exportan como análisis adicional. Se conserva la comparación convencional para reproducir las cifras entregadas.","",
  "Fuente: https://justinmshea.github.io/wooldridge/reference/labsup.html. Enunciado docente: Mauricio Tejada, Ejercicio Empírico 1: Margen Intensivo de la Participación Laboral Femenina."
))
