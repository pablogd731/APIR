library(httr)
library(stringr)

#crear funcion para crear obtener la lista de los urls
conseguir_links <- function(api_key, simbolo, funcion){
  
  lista_direcciones <-list()
  for( i in 1:length(simbolo)){
    ticker<-simbolo[i]
    link <- str_c("https://www.alphavantage.co/query?function=",funcion,"&symbol=",
              ticker,"&apikey=",api_key)
    lista_direcciones [[i]] <- link 
  }
  return(lista_direcciones)
}

# valores para conseguir links 
api_key <- 'AA820F3E8D40E9D3'
funcion<-'INCOME_STATEMENT'
simbolo<-c('SPCE', 'MS',	'AL',	'MG',	'NVDA',		'ROKU',	'F',	'GO',	'GEO',
             'STL','KO',	'AM',	'GE',	'GME', 'BABA', 'CRSR', 'WISH',
             'PG',	'PEP',	'NKE',	'QS',	'PLTR',	'NIO',	'GS',	'HITI', 'MU')

#Llamar a mi funcion
links <- conseguir_links(api_key, simbolo, funcion)

#Crear matriz de links 
links<-as.matrix(links)

#renombrar columnas y filas 
rownames(links)<-simbolo
colnames(links)<-str_c("Direcciones de ",funcion)

#conseguir datos de las apis 
library(jsonlite)
scraping<- function(links){
  reporte<-list()
  for(k in links){
    datos<-GET(k)
    datos<-fromJSON((content(datos, type = "text")))
    reporte[[k]] <- datos
    Sys.sleep(15)
  }
  return(reporte)
}

#Extraer datos 
mi_reporte <- scraping(links)

#Renombrar lista 
names(mi_reporte)<-simbolo

#ver lista en una dataframe 

spce<-data.frame(mi_reporte[["SPCE"]][["annualReports"]])

#Trasponer dataframe
spce<-t(spce)
colnames(spce)<-spce[1,]
spce<-spce[-1,]
spce_new<-as.numeric(spce)
crsr<-mi_reporte[["CRSR"]]
crsr<-crsr[["quarterlyReports"]]
crsr<-t(crsr)
colnames(crsr)<-crsr[1,]
crsr<-crsr[-1,]


#exporta datos 
library(rio)
setwd("C:\\Users\\Pablo Garcia\\Documents\\Documentos R\\")
export(crsr, "crsr.xlsx")
