d<-as.data.frame(readxl::read_excel(original_file("oil_shocks.xlsx"),.name_repair="minimal"))
names(d)<-c("date_text","oil_price","INDPRO","O_supplied")
d$date<-as.Date(paste0(gsub(":","-",d$date_text),"-01"))
stopifnot(nrow(d)==708L,!anyNA(d$date),!anyDuplicated(d$date),all(d$INDPRO>0),all(d$oil_price>0))
d<-d[order(d$date),];stopifnot(all(format(d$date,"%Y-%m")==format(seq(d$date[1],by="month",length.out=nrow(d)),"%Y-%m")))
d$ln_indpro<-log(d$INDPRO);d$g<-c(NA,100*diff(d$ln_indpro))
oil_shock<-function(price,k) {
  v<-rep(NA_real_,length(price))
  for(t in (k+1):length(price)) v[t]<-100*max(0,log(price[t]/max(price[(t-k):(t-1)])))
  v
}
d$O_12<-oil_shock(d$oil_price,12);d$O_36<-oil_shock(d$oil_price,36)
audit<-do.call(rbind,lapply(c(12,36),function(k){
 delta<-d$O_supplied-d[[paste0("O_",k)]];x<-delta[is.finite(delta)]
 data.frame(window_months=k,compared=length(x),max_abs_difference=max(abs(x)),mismatches=sum(abs(x)>1e-8))}))
put(audit,"auditoria_definicion_shock.csv")
stopifnot(audit$mismatches[audit$window_months==36]==0L)
put(d[,c("date","ln_indpro","g","O_supplied","O_12","O_36")],"series_transformadas.csv")

# Selección ADF: misma ventana temporal para todos los órdenes candidatos.
adf_select<-function(y,type,maxp=12L) {
  dy<-diff(y);base<-data.frame(delta=dy,ylag=head(y,-1),trend=2:length(y))
  for(k in 1:maxp) base[[paste0("L",k)]]<-lag_vector(dy,k)
  base<-base[complete.cases(base),]
  tab<-do.call(rbind,lapply(0:maxp,function(p){
    rhs<-c("ylag",if(type=="trend") "trend",if(p>0) paste0("L",1:p))
    m<-lm(reformulate(rhs,"delta"),data=base)
    data.frame(p=p,n=nobs(m),AIC=AIC(m))
  }))
  p<-tab$p[which.min(tab$AIC)];test<-urca::ur.df(y,type=type,lags=p)
  tau<-test@teststat[1,1];critical<-test@cval[1,"5pct"]
  list(selection=tab,result=data.frame(series=type,p=p,tau=tau,critical_5pct=critical,
    reject_unit_root_5pct=tau<critical))
}
adf_level<-adf_select(d$ln_indpro,"trend");adf_growth<-adf_select(na.omit(d$g),"drift")
put(rbind(transform(adf_level$selection,series="log nivel"),transform(adf_growth$selection,series="crecimiento")),"seleccion_ADF_AIC_muestra_comun.csv")
adf_results<-rbind(transform(adf_level$result,series="log nivel"),transform(adf_growth$result,series="crecimiento"))
put(adf_results,"resultados_ADF.csv")
# Reconstruye la selección antigua solo como diagnóstico del código entregado.
legacy<-do.call(rbind,lapply(c("trend","drift"),function(type){
 y<-if(type=="trend")d$ln_indpro else na.omit(d$g)
 do.call(rbind,lapply(0:12,function(p){a<-urca::ur.df(y,type=type,lags=p);r<-a@testreg
  n<-length(residuals(r));data.frame(type=type,p=p,n=n,k_incorrect=length(coef(r)),
    AIC_incorrect=n*log(sum(residuals(r)^2)/n)+2*length(coef(r)))}))
}))
put(legacy,"diagnostico_AIC_original.csv")

make_dl<-function(O,label,force_common=FALSE) {
  x<-data.frame(date=d$date,g=d$g)
  for(j in 0:18) x[[paste0("L",j)]]<-lag_vector(O,j)
  keep<-complete.cases(x)
  if(force_common) keep<-keep & common_rows
  x<-x[keep,];m<-lm(g~.-date,data=x)
  V<-sandwich::NeweyWest(m,lag=18,prewhite=FALSE)
  co<-coef_table(m,label,V,normal=TRUE)
  b<-coef(m)[-1];VB<-V[-1,-1,drop=FALSE]
  q<-length(b);W<-as.numeric(t(b)%*%solve(VB,b));F<-W/q
  test<-data.frame(specification=label,n=nobs(m),start=as.character(min(x$date)),
    end=as.character(max(x$date)),F_HAC=F,df1=q,df2=df.residual(m),
    p_value=pf(F,q,df.residual(m),lower.tail=FALSE))
  se<-sqrt(diag(VB));cum_se<-sqrt(vapply(seq_along(b),function(i)sum(VB[1:i,1:i]),numeric(1)))
  effects<-data.frame(specification=label,horizon=0:18,beta=unname(b),
    lower95=unname(b)-qnorm(.975)*se,upper95=unname(b)+qnorm(.975)*se,
    cumulative=unname(cumsum(b)),cumulative_lower95=unname(cumsum(b))-qnorm(.975)*cum_se,
    cumulative_upper95=unname(cumsum(b))+qnorm(.975)*cum_se)
  list(coefs=co,test=test,effects=effects)
}
xx<-sapply(0:18,function(j)lag_vector(d$O_supplied,j))
common_rows<-complete.cases(cbind(d$g,xx))
fits<-list(make_dl(d$O_supplied,"Provisto_36_meses"),make_dl(d$O_12,"Formula_12_meses"),
            make_dl(d$O_12,"12_meses_muestra_comun",TRUE))
tests<-do.call(rbind,lapply(fits,`[[`,"test"));effects<-do.call(rbind,lapply(fits,`[[`,"effects"))
put(tests,"contrastes_conjuntos_HAC.csv");put(effects,"multiplicadores.csv")
put(do.call(rbind,lapply(fits,`[[`,"coefs")),"coeficientes_HAC.csv")
repro<-data.frame(statistic="F conjunto HAC, shock provisto",reference=5.23,reproduced=tests$F_HAC[1],tolerance=.01)
repro$difference<-repro$reproduced-repro$reference;repro$matches<-abs(repro$difference)<=repro$tolerance
put(repro,"reproduccion_entrega.csv")
save_plot(ggplot2::ggplot(effects,ggplot2::aes(horizon,cumulative))+
 ggplot2::geom_hline(yintercept=0,linetype=2,colour="grey60")+
 ggplot2::geom_ribbon(ggplot2::aes(ymin=cumulative_lower95,ymax=cumulative_upper95),fill="#208070",alpha=.15)+
 ggplot2::geom_line(colour="#173F5F",linewidth=.8)+ggplot2::facet_wrap(~specification,ncol=1)+
 ggplot2::labs(title="Respuesta acumulada del crecimiento industrial",subtitle="Cambio aproximado en nivel por un punto de shock; IC HAC 95%",
 x="Meses desde la innovación",y="Suma de coeficientes",caption="Las especificaciones difieren en definición y, cuando se indica, muestra.")+theme_portfolio(),"multiplicadores_acumulados.png",8,8)
save_plot(ggplot2::ggplot(effects,ggplot2::aes(horizon,beta))+
 ggplot2::geom_hline(yintercept=0,linetype=2,colour="grey60")+
 ggplot2::geom_errorbar(ggplot2::aes(ymin=lower95,ymax=upper95),width=.15,colour="#173F5F")+
 ggplot2::geom_point(colour="#208070",size=1.5)+ggplot2::facet_wrap(~specification,ncol=1)+
 ggplot2::labs(title="Multiplicadores dinámicos",x="Rezago mensual",y="Puntos de crecimiento por punto de shock")+theme_portfolio(),"multiplicadores_dinamicos.png",8,8)
plot_data<-rbind(data.frame(date=d$date,value=d$ln_indpro,series="Log producción industrial"),
 data.frame(date=d$date,value=d$g,series="Crecimiento mensual (%)"),
 data.frame(date=d$date,value=d$O_supplied,series="Shock suministrado (36 meses)"))
save_plot(ggplot2::ggplot(plot_data,ggplot2::aes(date,value))+
 ggplot2::geom_line(colour="#173F5F",na.rm=TRUE)+ggplot2::facet_wrap(~series,ncol=1,scales="free_y")+
 ggplot2::labs(title="Series mensuales, 1955–2013",x=NULL,y=NULL)+theme_portfolio(),"series.png",8,8)
report(c("# EE5: shock petrolero y producción industrial","",
 "La base tiene 708 meses, enero de 1955 a diciembre de 2013. La mención de una contracción de 2020 en la entrega no corresponde a esta muestra y se retira.","",
 "## Diferencia entre archivo y enunciado","",md_table(audit),
 "La columna 0_T coincide con aumentos netos sobre el máximo de los 36 meses anteriores, no de los 12 meses de la fórmula del enunciado. Los 36 NA iniciales se conservan como observaciones no calculables; no se sustituyen por cero. Se reproduce la medida suministrada y se añade la fórmula de 12 meses sobre muestra completa y sobre la misma muestra de la entrega.","",
 "## Raíz unitaria","",md_table(adf_results),
 "Se corrige el conteo de parámetros del AIC y se comparan órdenes 0–12 sobre una misma ventana. El test seleccionado se reestima con las observaciones disponibles para ese orden. No rechazar la raíz unitaria no demuestra que la serie sea I(1); se evalúa conjuntamente la evidencia en diferencias. Los valores críticos son ADF, no t convencionales.","",
 "## Modelo DL(0–18) e inferencia","",md_table(tests),
 "Se usan covarianzas Newey–West con 18 rezagos y sin preblanqueo, como en la entrega. El Wald contrasta que los 19 coeficientes sean conjuntamente cero. La significancia de ese contraste no equivale a probar que su suma sea distinta de cero.","",
 "![Acumulados](figures/multiplicadores_acumulados.png)","",
 "Cada beta mide puntos porcentuales de crecimiento mensual industrial por un punto de la medida de shock. La suma hasta h aproxima el cambio porcentual del nivel de producción acumulado hasta ese horizonte ante un shock puntual. Sus intervalos incorporan todas las covarianzas entre coeficientes; no se suman errores estándar.","",
 "## Exogeneidad: pregunta 6 del enunciado","",
 "Si una mayor actividad de Estados Unidos eleva el precio del petróleo, la medida petrolera puede correlacionarse con perturbaciones de la producción industrial. El modelo DL no identifica por sí solo efectos causales; HAC corrige la inferencia frente a heterocedasticidad y autocorrelación, no la endogeneidad. También pueden existir variables omitidas y heterogeneidad entre shocks de oferta y demanda petrolera.","",
 "## Reproducción de la entrega","",md_table(repro),
 "Fuente docente: Mauricio Tejada, Ejercicio Empírico 5: El Impacto de los Shocks en el Precio del Petróleo. La última pregunta y la fórmula de 12 meses se incorporan explícitamente. Archivo fuente: oil_shocks.xlsx, conservado por hash."
))
