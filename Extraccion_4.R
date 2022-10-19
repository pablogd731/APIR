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
#simbolo <- c('TSLA', 'CRSR')


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
    Sys.sleep(13)
  }
  return(reporte)
}

#Extraer datos 
mi_reporte <- scraping(links)

#Renombrar lista 
names(mi_reporte)<-simbolo

#Hojas de balance
hoja_de_balances <- conseguir_links(api_key, simbolo, "BALANCE_SHEET")
hoja_de_balances <- as.matrix(hoja_de_balances)
hoja_de_balances <- scraping(hoja_de_balances)
names(hoja_de_balances) <- simbolo

#Cash flow 
cash_flow <- conseguir_links(api_key,simbolo, "CASH_FLOW") 
cash_flow <- as.matrix(cash_flow)
cash_flow <- scraping(cash_flow)
names(cash_flow) <- simbolo

#Convertir lista en data frame 
#install.packages('plyr')

library(plyr)
cash_flow.df <- do.call("rbind", lapply(cash_flow, as.data.frame)) 
hoja_de_balances.df <- do.call("rbind", lapply(hoja_de_balances, as.data.frame)) 
mi_reporte.df <- do.call("rbind", lapply(mi_reporte, as.data.frame)) 

#Exportar datos a excel 
library(rio)
setwd("C:\\Users\\Pablo Garcia\\Documents\\Documentos R\\")
export(cash_flow.df, "Cash_flow.xlsx")
export(hoja_de_balances.df, "Hojas_de_Balances.xlsx")
export(mi_reporte.df, "Income_Statement.xlsx")


for(h in hoja_de_balances.df){
  print(h)
}
