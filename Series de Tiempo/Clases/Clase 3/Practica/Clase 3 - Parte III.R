##########################################################
#             ANALISIS DE SERIES TEMPORALES              #
#	            MAESTRIA EN CIENCIA DE DATOS               #
#                FACULTAD DE INGENIERIA                  #
#                 UNIVERSIDAD AUSTRAL                    #
##########################################################

## Asignatura: ANALISIS DE SERIES TEMPORALES
## Docente: Rodrigo Del Rosso

################################
####### SETEO DE CARPETA #######
################################
rm(list = ls())
.rs.restartR() ## reiniciar sesión

path = "..........." ## incorporar directorio de trabajo
setwd(path)

## CARGAR FUNCIONES PROGRAMADAS

source(paste0(path,"Funciones.R"))

#####################
## CARGAR PAQUETES ##
#####################

suppressPackageStartupMessages({
  library(tseries)
  library(forecast)
  library(ggplot2)
  library(gridExtra)
  library(car)
  library(nortest)
  library(AdequacyModel)
  library(lmtest)
  library(quantmod)
  library(dygraphs)
  library(lessR)
})

## CARGAR DATASET
library(readxl)
datos <- read_excel("ts3.xlsx")
datos_ts <- ts(datos$trafico, start = 2010, frequency = 12)

## ANALISIS VISUALES

autoplot(datos_ts, 
         main = "Pasajeros Aerocomerciales BUE-COR")

acf(datos_ts, 
    type = "cov",  
    main = "Funcion de Autocovarianza")

## ACF,PACF

par(mfrow = c(1,2))
g1 <- acf(datos_ts, main="Funcion de Autocorrelacion")
g2 <- pacf(datos_ts, main="Funcion de Autocorrelacion Parcial")

# DIFERENCIACION DE LA SERIE PARA TRATAR DE HACERLA ESTACIONARIA
d_datos_ts <- diff(datos_ts)
ldatos_ts <- log(datos_ts)
d_ldatos_ts <- diff(ldatos_ts)

## ANALISIS VISUALES
autoplot(d_datos_ts, 
         main = "Pasajeros Aerocomerciales BUE-COR. primera diferencia")

autoplot(d_ldatos_ts, 
         main = "Pasajeros Aerocomerciales BUE-COR. primera diferencia del log")

v1 = autoplot(datos_ts) + 
  ggtitle("Trafico", subtitle = "BUE-COR") + 
  ylab("")

v2 = autoplot(d_datos_ts) + 
  ggtitle("1era Diferencia", subtitle = "BUE-COR") + 
  ylab("")

v3 = autoplot(ldatos_ts) + 
  ggtitle("Log Trafico", subtitle = "BUE-COR") +
  ylab("")

v4 = autoplot(d_ldatos_ts) + 
  ggtitle("1era Diferencia", subtitle = "Log Trafico BUE-COR") +
  ylab("")

grid.arrange(v1,v2,v3,v4)

## ACF Y PACF
par(mfrow=c(2,2))
acf(d_datos_ts, main="Autocorrelacion 1era Diferencia Niveles")
pacf(d_datos_ts, main="Autocorrelacion Parcial 1era Diferencia Niveles")
acf(d_ldatos_ts, main="Autocorrelacion 1era Diferencia Log")
pacf(d_ldatos_ts, main="Autocorrelacion Parcial 1era Diferencia Log")
