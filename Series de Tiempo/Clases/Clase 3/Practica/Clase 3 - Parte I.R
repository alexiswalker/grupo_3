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

#################
## TIME SERIES ##
#################

## Modelos MA ##

set.seed(123)
theta1 = 0.80
ma_1 <- arima.sim(n = 100,
                  model = list(ar = NULL,ma = theta1),
                  sd = 1)

autoplot(ma_1) + 
  ggtitle("MA(1) Simulado") +
  labs(subtitle = bquote(theta == .(theta1))) + 
  ylab("")

## Incorrelación
Box.test(ma_1,lag = 1,type = "Ljung-Box")

# Función de Autocorrelación FAC

ggAcf(ma_1) + 
  ggtitle("MA(1)") + 
  labs(subtitle = bquote(theta == .(theta1)))

# Función de Autocorrelación Parcial (FACP  - PACF)

ggAcf(ma_1, type = "partial") + 
  ggtitle("MA(1)") + 
  labs(subtitle = bquote(theta == .(theta1)))

## Estimación del modelo

modelo_ma = arima(ma_1,order = c(0,0,1))
summary(modelo_ma)

residuos <- resid(modelo_ma)

Box.test(residuos, lag = 1, type = "Ljung-Box")
Box.test(residuos, lag = 2, type = "Ljung-Box")
Box.test(residuos, lag = 3, type = "Ljung-Box")

## Modelos ARMA ##

### ARMA(1,1) ###

arma11 <- arima.sim(n=100,model = list(ar=0.80,ma=0.50),sd=1)

autoplot(arma11) + 
  ggtitle("ARMA(1,1) Simulado")

# Función de Autocorrelación FAC

ggAcf(arma11) + 
  ggtitle("ARMA(1,1)")

# Función de Autocorrelación Parcial (FACP  - PACF)

ggAcf(arma11, type = "partial") + 
  ggtitle("ARMA(1,1)")

### ARMA(2,2) ###

set.seed(234)
arma22 <- arima.sim(n=100,model=list(ar = c(0.3,0.6),ma = c(2,3)))

autoplot(arma22) + 
  ggtitle("ARMA(2,2) Simulado")

# Función de Autocorrelación FAC

ggAcf(arma22) + 
  ggtitle("ARMA(2,2)")

# Función de Autocorrelación Parcial (FACP  - PACF)

ggAcf(arma22, type = "partial") + 
  ggtitle("ARMA(2,2)")

### PARSIMONIA ###

set.seed(123)
x1 <- arima.sim(n=100,model=list(ar=c(0.90,-0.20),ma=c(-1.30,0.40)),sd=1)

set.seed(123)
x2 <- arima.sim(n=100,model=list(ar=c(0.40),ma=c(-0.80)),sd=1)

p1 = autoplot(x1) + ggtitle("ARMA(2,2) Simulado")
p2 = autoplot(x2) + ggtitle("ARMA(1,1) Simulado")

grid.arrange(p1, p2, ncol=2)

## Criterios de Información

AIC_Matrix(ar_1,p.order = 2,q.order = 2)
AIC_Matrix(ma_1,p.order = 2,q.order = 2)

## Eliminar Objetos ##

rm(list = ls())