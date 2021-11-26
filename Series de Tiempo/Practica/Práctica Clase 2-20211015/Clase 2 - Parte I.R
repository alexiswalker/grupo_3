##########################################################
#             ANÁLISIS DE SERIES TEMPORALES              #
#	            MAESTRÍA EN CIENCIA DE DATOS               #
#                FACULTAD DE INGENIERÍA                  #
#                 UNIVERSIDAD AUSTRAL                    #
##########################################################

## Asignatura: ANÁLISIS DE SERIES TEMPORALES
## Docentes: Rodrigo Del Rosso

################################
####### SETEO DE CARPETA #######
################################
rm(list = ls())

path = "..........." ## incorporar directorio de trabajo
setwd(path)

## CARGAR FUNCIONES PROGRAMADAS

source("Funciones.R")

#####################
## CARGAR PAQUETES ##
#####################

suppressPackageStartupMessages({
  library(tseries)
  library(forecast)
  library(ggplot2)
  library(gridExtra)
})

#################
## TIME SERIES ##
#################

# Simular un WN
white_noise <- arima.sim(model = list(order = c(0, 0, 0)), 
                           n = 100)

# Graficar white_noise
autoplot(white_noise) + 
  ggtitle("Ruido Blanco", subtitle = "Con Media") + 
  ylab("")

# RANDOM WALK
rw <- arima.sim(model = list(order = c(0, 1, 0)), 
                      n = 100)

# Graficar rw_drift
autoplot(rw, 
         main = "Random Walk", 
         ylab = "")

# Función de Autocorrelación (FAC - ACF)

g1 = ggAcf(white_noise) + ggtitle("Ruido Blanco")
g2 = ggAcf(rw) + ggtitle("Random Walk")
grid.arrange(g1,g2,ncol = 2)

# Test de Incorrelación - Box-Pierce y Ljung-Box

library(tseries)
Box.test(white_noise,lag = 1,type = "Box-Pierce")
Box.test(white_noise,lag = 1,type = "Ljung-Box")

# Con más lags

Box.test(white_noise,lag = 2,type = "Ljung-Box")
Box.test(white_noise,lag = 3,type = "Ljung-Box")

## Random Walk

Box.test(rw,lag = 1,type = "Ljung-Box")
Box.test(rw,lag = 2,type = "Ljung-Box")

Incorrelation(white_noise,"Ljung-Box")


inco_wn = Incorrelation(white_noise,"Ljung-Box")

autoplot(ts(inco_wn$P_Value)) +
  ggtitle("Test de Ljung-Box", subtitle = "P-Value") +
  ylab("")

## MODELO AR(1) ##

set.seed(123)
phi1 = 0.80
ar_1 <- arima.sim(n = 1000,
                  model = list(ar = phi1,ma = NULL),
                  sd = 1)

autoplot(ar_1) + 
  ggtitle("AR(1) Simulado") +
  labs(subtitle = bquote(phi == .(phi1))) + 
  ylab("")

## Autocovarianzas

acf(ar_1,type = "covariance",plot = F)

## Autocorrelaciones

acf(ar_1,type = "correlation",plot = F)

## Incorrelación
Box.test(ar_1,lag = 1,type = "Ljung-Box")
Box.test(ar_1,lag = 2,type = "Ljung-Box")

# Función de Autocorrelación Parcial (FACP  - PACF)

h1 = ggAcf(white_noise,type = "partial") + ggtitle("Ruido Blanco")
h2 = ggAcf(rw,type = "partial") + ggtitle("Random Walk")
h3 = ggAcf(ar_1,type = "partial") + ggtitle("AR(1)") + labs(subtitle = bquote(phi == .(phi1)))

grid.arrange(h1,h2,h3, ncol = 2)

## Estimación

modelo <- arma(ar_1,order = c(1,0), include.intercept = T)

coef(modelo)

summary(modelo)

## Análisis de los Residuos

residuos <- resid(modelo)

library(lessR)
Histogram(residuos,density = T)

# Grafico los residuos
plot(residuos, main="Ploteo los residuos del modelo AR(1)", xlab="Tiempo", ylab="Valores",col="6")

# Grafico un histograma de los residuos
Histogram(residuos,density = T)

library(tseries)
jarque.bera.test(na.omit(residuos))

Normality_Test(na.omit(residuos),type = "JB")
Normality_Test(na.omit(residuos),type = "AD")
Normality_Test(na.omit(residuos),type = "SW")

Box.test(residuos,lag = 1)
Incorrelation(residuos,"Ljung-Box")

## Otra forma de estimar los coeficientes

modelo2 <- arima(ar_1,order = c(1,0,0),method = "ML")
summary(modelo2)

modelo3 <- arima(ar_1,order = c(1,0,0),method = "CSS")
summary(modelo3)

modelo4 <- ar(ar_1, method = "yule-walker")
print(modelo4)
summary(modelo4)

modelo4$method

## Eliminar Objetos ##

rm(list = ls())
