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
  library(PASWR2)
  library(dplyr)
  library(psych)
  library(pastecs)
  library(astsa)
  library(tseries)
  library(zoo)
  library(xts)
  library(fma)
  library(expsmooth)
  library(Quandl)
  library(fpp)
  library(urca)
  library(AER)
  library(fUnitRoots)
  library(CADFtest)
  library(fpp2)
  library(datasets)
  library(tidyverse)
  library(magrittr)
  library(ggfortify)
  library(gamlss.data)
  library(vars)
  library(urca)
  library(lmtest)
  library(forecast)
  library(ggplot2)
  library(reshape2)
  library(ggfortify)
  library(readxl)
  library(psych)
  library(DataExplorer)
  library(timetk)
  library(keras)
  library(dplyr)
})

# FUENTE DEL EJERCICIO: https://rpubs.com/ryankelly/tsa6
# OTRO EJEMPLO: https://rpubs.com/pjmurphy/383854
# EJERCICIO Y LECTURA COMPLEMENTARIA: https://otexts.com/fpp2/arima-r.html
# VIDEOS MUY DIDÁCTICOS SOBRE LA TEORÍA DE SERIES DE TIEMPO Y OTROS TEMAS DE DATA MINING:
# https://www.youtube.com/channel/UCUcpVoi5KkJmnE3bvEhHR0Q

# Cargo los datos. Este conjunto de datos registra la edad de muerte de 42 reyes sucesivos de Inglaterra
base <- scan('http://robjhyndman.com/tsdldata/misc/kings.dat', skip=3)
base

# Hago un primer análisis exploratorio de la base
psych::describe(base)
plot_histogram(base) 

# Defino la serie temporal y la ploteo
ts <- ts(base)
autoplot(ts, ts.colour = 'dark blue')+ ggtitle("Edad") + ylab("")

# Grafico la ACF y PACF
par(mfrow=c(1,2))
g1<-acf(ts, main="Funcion de Autocorrelacion")
g2<-pacf(ts, main="Funcion de Autocorrelacion Parcial")

# VERIFICO LA ESTACIONARIEDAD

# 1) LJUNG - BOX

# Planteo el test de Ljung-Box. Si rechazo H0 significa que hay coeficientes de autocorrelación distintos a cero
Incorrelation(ts,"Ljung-Box") # Ver función autocorrelación al incio del script
inco_wn = Incorrelation(ts,"Ljung-Box")
autoplot(ts(inco_wn$P_Value)) + ggtitle("Test de Ljung-Box", subtitle = "P-Value") + ylab("") # Grafico los p-value para disntitos lags

# 2) DICKEY-FULLER

#H0: RAIZ UNITARIA (NO ESTACIONARIO) 
#H1: NO HAY RAIZ UNITARIA (ESTACIONARIO)
adf.test(ts)
# p-value = 0.529 - No Rechazo H0, no estacionario

# Si los estadístícos son menores a los valores críticos, se rechaza H0. La serie es estacionaria
summary(ur.df(ts, type = "none", selectlags = c("AIC")))
summary(ur.df(ts, type = "drift", selectlags = c("AIC")))
summary(ur.df(ts, type = "trend", selectlags = c("AIC")))

# 3) KPSS

#H0: ESTACIONARIO
#H1: NO ESTACIONARIO
kpss.test(ts)
# p-value = 0.04362 - Rechazo H0, no estacionario

# Diferenciamos la serie para hacerla estacionaria
tsd <- diff(ts, difference=1)  # First-order differencing
autoplot(tsd, ts.colour = 'dark blue')+ ggtitle("1ra Dif Edad") + ylab("")

# Grafico la ACF y PACF
par(mfrow=c(1,2))
g1<-acf(tsd, main="Funcion de Autocorrelacion")
g2<-pacf(tsd, main="Funcion de Autocorrelacion Parcial")

# La ACF da una idea del orden del MA. Posbile orden 1
# La PACF da una idea del orden del AR. Posible orden 3

# VERIFICO LA ESTACIONARIEDAD

# 1) LJUNG - BOX

# Planteo el test de Ljung-Box. Si rechazo H0 significa que hay coeficientes de autocorrelación distintos a cero: hay autocorrelación
Incorrelation(tsd,"Ljung-Box") # Ver función autocorrelación al incio del script
inco_wn = Incorrelation(tsd,"Ljung-Box")
autoplot(ts(inco_wn$P_Value)) + ggtitle("Test de Ljung-Box", subtitle = "P-Value") + ylab("") # Grafico los p-value para disntitos lags

# 2) DICKEY-FULLER

#H0: RAIZ UNITARIA (NO ESTACIONARIO) 
#H1: NO HAY RAIZ UNITARIA (ESTACIONARIO)
adf.test(tsd)
# p-value = 0.01654 - Rechazo H0, estacionario

# Si los estadístícos son menores a los valores críticos, se rechaza H0. La serie es estacionaria
summary(ur.df(tsd, type = "none", selectlags = c("AIC")))
summary(ur.df(tsd, type = "drift", selectlags = c("AIC")))
summary(ur.df(tsd, type = "trend", selectlags = c("AIC")))

# 3) KPSS

#H0: ESTACIONARIO
#H1: NO ESTACIONARIO
kpss.test(tsd)
# p-value = 0.1 - No rechazo H0, estacionario

# A) MODELADO - MÉTODO MANUAL
# A partir de las gráficas de ACF y PACF planteamos 3 modelos
arima1 <- arima(tsd, order=c(3, 0, 1))
arima2 <- arima(tsd, order=c(2, 0, 1))
arima3 <- arima(tsd, order=c(3, 0, 0))

arima1$aic # 350.5172
arima2$aic # 349.0241
arima3$aic # 348.5243 menor AIC

# Tomamos el modelo 3. Verificamos los residuos. Explicación sobre la importancia de los residuos: https://otexts.com/fpp2/residuals.html
residuos <- resid(arima3)

# Verifico la normalidad de los residuos
# H0: NORMALIDAD
Normality_Test(na.omit(residuos),type = "JB") 
Normality_Test(na.omit(residuos),type = "AD")
Normality_Test(na.omit(residuos),type = "SW") 
# Con lo tres test no rechazo el supuesto de normalidad

# Planteo el test de Ljung-Box. Si rechazo H0 significa que hay coeficientes de autocorrelación distintos a cero: hay autocorrelación
Incorrelation(residuos,"Ljung-Box")
inco_wn = Incorrelation(residuos,"Ljung-Box")

# Grafico los p-value para disntitos lags
autoplot(ts(inco_wn$P_Value)) +
  ggtitle("Test de Ljung-Box", subtitle = "P-Value") +
  ylab("")
# todos los p-value son mayores a 0.05. No hay autocorrelación.

# Chequeo los residuos
checkresiduals(arima3)

# B) MODELADO - MÉTODO AUTOMÁTICO

arima4 <- auto.arima(tsd)
arima4 # ARIMA (0,0,1)
arima4$aic # 344.128

arima5 <- auto.arima(ts)
arima5 # Si planteo un autoarima a la serie original, me incluye el término d=1

# Verificamos los residuos
residuos <- resid(arima4)

# Verifico la normalidad de los residuos
# H0: NORMALIDAD
Normality_Test(na.omit(residuos),type = "JB") 
Normality_Test(na.omit(residuos),type = "AD")
Normality_Test(na.omit(residuos),type = "SW") 
# Con lo tres test no rechazo el supuesto de normalidad

# Planteo el test de Ljung-Box. Si rechazo H0 significa que hay coeficientes de autocorrelación distintos a cero
Incorrelation(residuos,"Ljung-Box")
inco_wn = Incorrelation(residuos,"Ljung-Box")

# Grafico los p-value para disntitos lags
autoplot(ts(inco_wn$P_Value)) +
  ggtitle("Test de Ljung-Box", subtitle = "P-Value") +
  ylab("")
# todos los p-value son mayores a 0.05. No rechazo el supuesto de incorrelación (independencia)

# Chequeo los residuos
checkresiduals(arima4)