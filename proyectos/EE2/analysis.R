d<-utils::read.csv(original_file("datos_vivienda_did.csv"))
stopifnot(nrow(d)==30000L,!anyNA(d),!anyDuplicated(d$id),all(d$precio_uf>0),
          setequal(d$periodo,0:2),all(d$distancia_metro>=0 & d$distancia_metro<=4))
d$tratado<-as.integer(d$distancia_metro<2);pre<-subset(d,periodo %in% 0:1)
covars<-c("metros_cuadrados","num_habitaciones","colegio_cerca","parque_cerca")
balance<-do.call(rbind,lapply(covars,function(v){
  a<-pre[[v]][pre$tratado==1];b<-pre[[v]][pre$tratado==0];tt<-t.test(a,b)
  data.frame(variable=v,mean_treated=mean(a),mean_control=mean(b),difference=mean(a)-mean(b),
    smd=(mean(a)-mean(b))/sqrt((var(a)+var(b))/2),p_value=tt$p.value,
    lower95=tt$conf.int[1],upper95=tt$conf.int[2])}))
put(balance,"balance_Welch.csv")
put(do.call(rbind,lapply(covars,function(v){m<-lm(reformulate("tratado",v),data=pre)
  coef_table(m,v,sandwich::vcovHC(m,type="HC1"))})),"regresiones_balance_HC1.csv")
logit0<-glm(tratado~1,data=pre,family=binomial())
logit1<-glm(tratado~metros_cuadrados+num_habitaciones+colegio_cerca+parque_cerca,data=pre,family=binomial())
lr<-lmtest::lrtest(logit0,logit1)
put(data.frame(statistic=lr$Chisq[2],df=lr$Df[2],p_value=lr$`Pr(>Chisq)`[2]),"balance_conjunto.csv")
trend<-aggregate(precio_uf~tratado+periodo,data=d,FUN=mean);trend$group<-ifelse(trend$tratado==1,"Tratado (<2 km)","Control (2–4 km)")
put(trend,"promedios_grupo_periodo.csv")
p12<-subset(d,periodo %in% 1:2);p12$post<-as.integer(p12$periodo==2)
models<-list(nivel_sin_controles=lm(precio_uf~tratado*post,data=p12),
 log_sin_controles=lm(log(precio_uf)~tratado*post,data=p12),
 nivel_con_controles=lm(precio_uf~tratado*post+metros_cuadrados+num_habitaciones+colegio_cerca+parque_cerca,data=p12),
 log_con_controles=lm(log(precio_uf)~tratado*post+metros_cuadrados+num_habitaciones+colegio_cerca+parque_cerca,data=p12))
all<-do.call(rbind,Map(function(m,label)coef_table(m,label,sandwich::vcovHC(m,type="HC1")),models,names(models)))
put(all,"coeficientes_DiD_HC1.csv")
att<-all[all$term=="tratado:post",];att$unit<-ifelse(grepl("^log",att$model),"log precio","UF")
att$percent<-ifelse(att$unit=="log precio",100*expm1(att$estimate),NA_real_)
put(att,"efectos_DiD.csv")
pre$post<-as.integer(pre$periodo==1)
placebos<-list(nivel=lm(precio_uf~tratado*post,data=pre),log=lm(log(precio_uf)~tratado*post,data=pre))
placebo<-do.call(rbind,Map(function(m,label)coef_table(m,label,sandwich::vcovHC(m,type="HC1")),placebos,names(placebos)))
put(placebo[placebo$term=="tratado:post",],"placebo_pretratamiento.csv")
ref<-data.frame(model=c("nivel_sin_controles","nivel_con_controles","log_sin_controles","log_con_controles"),reference=c(452,495,8.7,9.6),tolerance=c(1,1,.15,.15))
repro<-merge(ref,att[,c("model","estimate","percent")],by="model")
repro$reproduced<-ifelse(grepl("^log",repro$model),repro$percent,repro$estimate)
repro$difference<-repro$reproduced-repro$reference;repro$matches<-abs(repro$difference)<=repro$tolerance
put(repro,"reproduccion_entrega.csv")
save_plot(ggplot2::ggplot(trend,ggplot2::aes(periodo,precio_uf,colour=group,group=group))+
 ggplot2::geom_line(linewidth=1)+ggplot2::geom_point(size=2.5)+
 ggplot2::scale_x_continuous(breaks=0:2)+ggplot2::scale_colour_manual(values=c("#173F5F","#208070"))+
 ggplot2::labs(title="Precios medios por grupo y periodo",subtitle="Caso docente con datos ficticios",
   x="Periodo: 0 y 1 antes; 2 después del anuncio",y="Precio (UF)",colour=NULL)+
 theme_portfolio()+ggplot2::theme(legend.position="bottom"),"tendencias_DiD.png")
report(c("# EE2: anuncio de Metro y precios de viviendas","",
 "**Caso docente con datos ficticios.** El tratamiento del enunciado es el anuncio de una estación futura, no su apertura. No se presenta como evaluación de una intervención real.","",
 "El archivo recibido contiene 30.000 transacciones con identificadores únicos: 10.000 por periodo. El enunciado describe 3.000; se documenta la diferencia y se usa el archivo efectivamente proporcionado, sin recortar observaciones para forzar coincidencia.","",
 "## Diferencias en diferencias","",md_table(att[,c("model","estimate","std_error","p_value","percent")]),
 "Las estimaciones en logaritmos se convierten mediante 100*(exp(beta)-1). Corresponden a cambios proporcionales del nivel ajustado bajo esa especificación; no se equiparan automáticamente con el ATT sobre el promedio aritmético de precios.","",
 "![Tendencias](figures/tendencias_DiD.png)","",
 "## Identificación y comprobaciones","",
 "Los datos son cortes transversales repetidos, no observaciones repetidas de la misma vivienda. Se usa HC1 como en el script original. Al no existir unidades geográficas de asignación identificadas, no se inventa una agrupación por observación ni se pretende resolver correlación espacial desconocida.","",
 "El balance observable no demuestra asignación aleatoria y no es condición necesaria del DiD básico. El placebo pretratamiento no significativo es compatible con tendencias paralelas, pero no las demuestra; solo existe una variación previa observable. También importan ausencia de anticipación, estabilidad de composición y de interferencias, y ausencia de shocks diferenciales no observados.","",
 "En un DiD logarítmico, el supuesto de tendencias paralelas se plantea para log(precio), no se deduce de comprobarlo en niveles. La inclusión de controles no elimina automáticamente todas las fuentes de sesgo.","",
 "Las cinco preguntas se abordan con balance, gráfico de tendencias, DiD en niveles y logaritmos, y ambos modelos con controles. El placebo y el balance conjunto son ampliaciones documentadas.","",
 "## Cifras de la entrega y archivo recibido","",md_table(repro[,c("model","reference","reproduced","difference","matches")]),
 "Las discrepancias, si aparecen, permanecen visibles. No se modifican datos ni coeficientes para obtener los números publicados."
))
