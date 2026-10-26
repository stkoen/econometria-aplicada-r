options(stringsAsFactors = FALSE)
original_file <- function(name) {
  path <- file.path(portfolio_root, "data", "originales", name)
  manifest <- jsonlite::fromJSON(file.path(portfolio_root, "data", "manifest.json"))
  expected <- manifest$sha256[manifest$file == name]
  if (length(expected) != 1L || !file.exists(path)) stop("Falta la base: ", name)
  stopifnot(digest::digest(file = path, algo = "sha256") == expected)
  path
}
public_data <- function(name) {
  meta <- jsonlite::fromJSON(file.path(portfolio_root,"data/public_sources.json"))[[name]]
  dir.create(file.path(portfolio_root,"data/publicas"),showWarnings=FALSE)
  path <- file.path(portfolio_root,"data/publicas",paste0(name,".RData"))
  if (!file.exists(path)) utils::download.file(meta$url,path,mode="wb",quiet=TRUE)
  stopifnot(digest::digest(file=path,algo="sha256")==meta$sha256)
  e <- new.env(); load(path,envir=e)
  get(name,envir=e,inherits=FALSE)
}
put <- function(x, name) utils::write.csv(x,file.path(out,name),row.names=FALSE,na="")
coef_table <- function(model,label,V=NULL,normal=FALSE) {
  if(is.null(V)) V <- stats::vcov(model)
  ct <- lmtest::coeftest(model,vcov.=V)
  q <- if(normal) stats::qnorm(.975) else stats::qt(.975,stats::df.residual(model))
  data.frame(model=label,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],
             statistic=ct[,3],p_value=ct[,4],lower95=ct[,1]-q*ct[,2],
             upper95=ct[,1]+q*ct[,2],row.names=NULL)
}
md_table <- function(x) {
  fmt <- function(v) {
    if(is.integer(v)) return(as.character(v))
    if(is.numeric(v)) return(ifelse(is.na(v),"NA",ifelse(abs(v)>0 & abs(v)<.0001,
      formatC(v,format="e",digits=3),formatC(v,format="f",digits=4))))
    gsub("|","/",as.character(v),fixed=TRUE)
  }
  x[] <- lapply(x,fmt)
  c(paste0("| ",paste(names(x),collapse=" | ")," |"),
    paste0("| ",paste(rep("---",ncol(x)),collapse=" | ")," |"),
    apply(x,1,function(v)paste0("| ",paste(v,collapse=" | ")," |")),"")
}
report <- function(lines) writeLines(enc2utf8(lines),file.path(out,"informe.md"),useBytes=TRUE)
theme_portfolio <- function() ggplot2::theme_minimal(base_size=12)+
  ggplot2::theme(panel.grid.minor=ggplot2::element_blank(),
                 plot.title=ggplot2::element_text(face="bold"))
save_plot <- function(p,name,width=8,height=4.8) {
  ggplot2::ggsave(file.path(out,"figures",name),p,width=width,height=height,dpi=170,bg="white")
}
lag_vector <- function(x,k) if(k==0) x else c(rep(NA_real_,k),head(x,-k))
