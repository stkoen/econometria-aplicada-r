e<-new.env();loaded<-load(original_file("datos_ecobaldur.RData"),envir=e)
stopifnot("data_ecobaldur" %in% loaded)
d<-e$data_ecobaldur;stopifnot(nrow(d)==100L,!anyNA(d),ncol(d)==3L)
x<-data.frame(u=d$Desempleo,dw=d$D_Salario_Real,dy=d$D_Productividad)
y<-ts(x,start=c(1995,1),frequency=4)
selection<-vars::VARselect(y,lag.max=3,type="const")
aic<-data.frame(p=1:3,t(selection$criteria),row.names=NULL)
put(aic,"criterios_rezagos.csv");p<-as.integer(selection$selection["AIC(n)"])
fit<-vars::VAR(y,p=p,type="const");roots<-vars::roots(fit)
put(data.frame(root_modulus=roots,stable=roots<1),"estabilidad.csv");stopifnot(all(roots<1))
co<-do.call(rbind,lapply(names(fit$varresult),function(v)coef_table(fit$varresult[[v]],v)))
put(co,"coeficientes_VAR.csv")
group<-do.call(rbind,lapply(names(x),function(cause){t<-vars::causality(fit,cause=cause)$Granger
 data.frame(cause=cause,statistic=unname(t$statistic),df1=unname(t$parameter[1]),
   df2=unname(t$parameter[2]),p_value=t$p.value)}))
put(group,"Granger_conjunto.csv")
pairwise<-do.call(rbind,lapply(names(x),function(response)do.call(rbind,lapply(setdiff(names(x),response),function(cause){
 m<-fit$varresult[[response]];terms<-paste0(cause,".l",1:p)
 a<-car::linearHypothesis(m,terms,test="F")
 data.frame(cause=cause,response=response,F=a$F[2],df1=a$Df[2],df2=a$Res.Df[2],p_value=a$`Pr(>F)`[2])
}))))
put(pairwise,"Granger_seis_direcciones_condicionales.csv")
ir<-vars::irf(fit,impulse=names(x),response=names(x),n.ahead=8,ortho=TRUE,boot=TRUE,
              ci=.95,runs=1000,seed=12345)
# La lista se indexa por impulso; las columnas de cada matriz, por respuesta.
irf<-do.call(rbind,lapply(names(ir$irf),function(shock)do.call(rbind,lapply(colnames(ir$irf[[shock]]),function(response){
 data.frame(shock=shock,response=response,horizon=0:8,value=ir$irf[[shock]][,response],
 lower95=ir$Lower[[shock]][,response],upper95=ir$Upper[[shock]][,response])
}))))
put(irf,"IRF_nueve_respuestas.csv")
stopifnot(nrow(irf)==81L,length(unique(paste(irf$shock,irf$response)))==9L)
fv<-vars::fevd(fit,n.ahead=8)
fevd<-do.call(rbind,lapply(names(fv),function(response)do.call(rbind,lapply(colnames(fv[[response]]),function(shock)
 data.frame(response=response,shock=shock,horizon=1:8,share=fv[[response]][,shock])))))
put(fevd,"FEVD.csv")
stopifnot(all(abs(aggregate(share~response+horizon,fevd,sum)$share-1)<1e-10))
alt<-vars::VAR(y[,c("dy","dw","u")],p=p,type="const")
alt_ir<-vars::irf(alt,impulse="dy",response="u",n.ahead=8,ortho=TRUE,boot=FALSE)
sensitivity<-data.frame(horizon=0:8,order_u_dw_dy=subset(irf,shock=="dy" & response=="u")$value,
                        order_dy_dw_u=as.numeric(alt_ir$irf$dy[,"u"]))
put(sensitivity,"sensibilidad_orden_respuesta_desempleo.csv")
ref<-data.frame(equation=c("u","dw","dy"),term=c("u.l1","dy.l1","dy.l1"),reference=c(.664,.350,.568))
repro<-merge(ref,co[,c("model","term","estimate")],by.x=c("equation","term"),by.y=c("model","term"))
repro$tolerance<-.001;repro$difference<-repro$estimate-repro$reference;repro$matches<-abs(repro$difference)<=repro$tolerance
put(repro,"reproduccion_entrega.csv");stopifnot(all(repro$matches),p==1L)
labels<-c(u="Desempleo (u)",dw="Variación salarial (dw)",dy="Variación productividad (dy)")
irf$shock<-factor(irf$shock,levels=names(x),labels=paste("Shock:",labels[names(x)]))
irf$response<-factor(irf$response,levels=names(x),labels=labels[names(x)])
save_plot(ggplot2::ggplot(irf,ggplot2::aes(horizon,value))+
 ggplot2::geom_hline(yintercept=0,colour="grey60",linetype=2)+
 ggplot2::geom_ribbon(ggplot2::aes(ymin=lower95,ymax=upper95),fill="#208070",alpha=.16)+
 ggplot2::geom_line(colour="#173F5F",linewidth=.65)+ggplot2::facet_grid(response~shock,scales="free_y")+
 ggplot2::labs(title="Baldur: las nueve funciones impulso–respuesta",
 subtitle="Orden u → dw → dy; innovaciones ortogonales de una desviación estándar",
 x="Trimestres",y="Respuesta",caption="Bandas puntuales 95% por 1.000 réplicas bootstrap; caso docente.")+theme_portfolio(),"IRF_nueve_paneles.png",11,9)
f8<-subset(fevd,horizon==8)
save_plot(ggplot2::ggplot(f8,ggplot2::aes(response,100*share,fill=shock))+
 ggplot2::geom_col()+ggplot2::scale_fill_manual(values=c("#173F5F","#208070","#D7A34A"))+
 ggplot2::labs(title="Composición de la varianza del error a ocho trimestres",x="Variable",y="Porcentaje",fill="Shock")+theme_portfolio(),"FEVD_horizonte_8.png")
quality<-data.frame(variable=names(x),minimum=vapply(x,min,numeric(1)),maximum=vapply(x,max,numeric(1)),
                     negatives=vapply(x,function(v)sum(v<0),integer(1)))
put(quality,"auditoria_series.csv")
report(c("# EE6: VAR del caso docente de Baldur","",
 "100 observaciones trimestrales, 1995–2019. El enunciado entrega las variaciones de salarios y productividad como cambios porcentuales y declara las diferencias estacionarias y las series desestacionalizadas. No se presentan primeras diferencias arbitrarias como tasas de crecimiento ni se atribuye la estacionariedad a una comprobación visual.","",
 "## Datos y alcance","",md_table(quality),
 "La serie llamada desempleo contiene valores negativos. No puede interpretarse literalmente como una tasa bruta real sin aclaración adicional de su construcción. Se conserva el archivo docente sin recortes ni desplazamientos y se limita la lectura a este sistema estilizado.","",
 "## Selección, coeficientes y estabilidad","",md_table(aic),
 sprintf("El orden seleccionado es %d y el máximo módulo de autovalor de la matriz compañera es %.4f (<1).",p,max(roots)),"",
 "## Identificación contemporánea","",
 "Se mantiene el orden solicitado u, dw, dy. En la convención Cholesky de vars, la primera variable no responde contemporáneamente a innovaciones de las siguientes: la primera es la más exógena contemporáneamente bajo esa restricción. La descripción del enunciado de primera variable como más endógena no coincide con esta convención. Se documenta, sin invertir silenciosamente el orden. La comparación con dy, dw, u permite observar sensibilidad a otra identificación.","",
 "## Nueve respuestas, correctamente identificadas","",
 "![IRF](figures/IRF_nueve_paneles.png)","",
 "Se corrige la extracción: cada elemento de la lista es un shock y cada columna una respuesta. Ahora se exportan las nueve combinaciones. La innovación ortogonal tiene una desviación estándar; no es necesariamente un aumento de una unidad de la variable observada. Las bandas son puntuales, no simultáneas para todas las curvas y horizontes.","",
 "Una respuesta que se disipa en la tasa de crecimiento no implica que desaparezca el efecto acumulado sobre el nivel. Tampoco una respuesta persistente durante ocho trimestres demuestra un efecto permanente.","",
 "## Causalidad de Granger","",md_table(pairwise),
 "Se exportan seis direcciones condicionadas en la tercera variable y, por separado, los tres contrastes conjuntos del script original. Rechazar un contraste conjunto no demuestra significancia en cada ecuación individual. Granger mide contenido predictivo incremental; no identifica causalidad estructural.","",
 "## Varianza del error de predicción","",md_table(f8),
 "Las participaciones se verifican para sumar uno por variable y horizonte. Su interpretación depende del orden de identificación y se limita a la varianza del error de pronóstico del modelo.","",
 "## Cifras originales reproducidas","",md_table(repro),
 "Fuente docente: Mauricio Tejada, Ejercicio Empírico 6: El Mercado Laboral de la Economía de Baldur. La corrección de gráficos afecta las interpretaciones gráficas; no modifica los coeficientes del VAR reducido."
))
