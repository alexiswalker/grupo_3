##########################################################
#             ANALISIS DE SERIES TEMPORALES              #
#	            MAESTRIA EN CIENCIA DE DATOS               #
#                FACULTAD DE INGENIERIA                  #
#                 UNIVERSIDAD AUSTRAL                    #
##########################################################

## Asignatura: ANALISIS DE SERIES TEMPORALES
## Docente: Rodrigo Del Rosso

# Limpio la memoria
rm(list = ls())
gc()

## .rs.restartR()

options(scipen = 999)

################################
####### SETEO DE CARPETA #######
################################

path = "D:/OneDrive - Facultad de Cs Económicas - UBA/Docencia/Posgrado/Austral/Análisis de Series Temporales/2021/Rosario/Práctica/Clase 4/"
setwd(path)

source(paste0(path,"Funciones.R"))

#####################
## CARGAR PAQUETES ##
#####################

suppressPackageStartupMessages({
  library(forecast)
  library(ggplot2)
  library(gridExtra)
  library(PASWR2)
  library(dplyr)
  library(psych)
  library(pastecs)
  library(astsa)
  library(lessR)
  library(tseries)
  library(zoo)
  library(xts)
  library(fma)
  library(expsmooth)
  library(lmtest)
  library(Quandl)
  library(fpp)
  library(urca)
  library(AER)
  library(fUnitRoots)
  library(CADFtest)
  library(fpp2)
  library(car)
  library(tseries)
  library(gridExtra)
  library(readxl)
})

## CARGAR DATOS

datos<-read_excel("ts3.xlsx")
datos_ts<-ts(datos$trafico, start = 2010, frequency = 12)

## ANALISIS VISUALES

autoplot(datos_ts, main="Pasajeros Aerocomerciales BUE-COR")

acf(datos_ts, type = "cov",  main="Funcion de Autocovarianza")

##ACF,PACF
par(mfrow=c(1,2))
g1<-acf(datos_ts, main="Funcion de Autocorrelacion")
g2<-pacf(datos_ts, main="Funcion de Autocorrelacion Parcial")


##TEST RAICES UNITARIAS
#H0: RAIZ UNITARIA ( NO ESTACIONARIO )
#H1: NO HAY RAIZ UNITARIA ( ESTACIONARIO )

##DICKEY-FULLER
# OPCION 1
df<-tseries::adf.test(datos_ts)  
df   

# OPCION 2 PAQUETE URCA

#TIPO 2
urca_trend<-urca::ur.df(datos_ts, selectlags = "AIC", type = "trend")
urca_trend
summary(urca_trend) # NO RECHAZO H0


#TIPO 1
urca_drift<-urca::ur.df(datos_ts, selectlags = "AIC", type = "drift")
urca_drift
summary(urca_drift) # NO RECHAZO H0

#TIPO 0
urca_none<-urca::ur.df(datos_ts, selectlags = "AIC", type = "none")
urca_none
summary(urca_none) # NO RECHAZO H0


##TEST KPSS
kpss.test(datos_ts)


#DIFERENCIACION DE LA SERIE PARA TRATAR DE HACERLA ESTACIONARIA
d_datos_ts<-diff(datos_ts)
ldatos_ts <- log(datos_ts)
d_ldatos_ts <- diff(ldatos_ts)


## ANALISIS VISUALES
autoplot(d_datos_ts, main="Pasajeros Aerocomerciales BUE-COR. primera diferencia")
autoplot(d_ldatos_ts, main="Pasajeros Aerocomerciales BUE-COR. primera diferencia del log")


###start
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
#####stop


##ACF Y PACF
par(mfrow=c(2,2))
acf(d_datos_ts, main="Autocorrelacion 1era Diferencia Niveles")
pacf(d_datos_ts, main="Autocorrelacion Parcial 1era Diferencia Niveles")
acf(d_ldatos_ts, main="Autocorrelacion 1era Diferencia Log")
pacf(d_ldatos_ts, main="Autocorrelacion Parcial 1era Diferencia Log")


#HACEMOS LOS TEST DE HIPOTESIS DE ESTACIONARIEDAD CON LAS TRANSFORMACIONES SELECCIONADAS
##DICKEY-FULLER
# OPCION 1
adf.test(d_datos_ts)
adf.test(d_ldatos_ts)

# OPCION 2
#TIPO 0
urca_none<-urca::ur.df(d_datos_ts, selectlags = "AIC", type = "none")
urca_none
summary(urca_none) 

# t <  Critical Value  --> # RECHAZAMOS H0 

#TIPO 0
urca_none<-urca::ur.df(d_ldatos_ts, selectlags = "AIC", type = "none")
# urca_none<-urca::ur.df(datos_ts, lags = 10, type = "none")
urca_none
summary(urca_none) # 

# t <  Critical Value  --> # RECHAZAMOS H0

# PARECE QUE CON LA PRIMERA DIFERENCIA YA CONVERTIMOS LA SERIA A ESTACIONARIA

## TEST KPSS
kpss.test(d_datos_ts)
kpss.test(d_ldatos_ts)

# Con las transformaciones trabajadas no hay condiciones para no rechazar H0, por lo tanto consideramos estacionariedad de los datos modificados trabajados"
