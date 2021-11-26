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

slope <- read.table(file = "slope.txt",
                    header = T)

curvature <- read.table(file = "curvature.txt",
                        header = T)

head(slope)
head(curvature)

## DESCRIPTIVA
library(pastecs)
stat.desc(slope$slope,norm = T)
stat.desc(curvature$curvature,norm = T)

## HISTOGRAMA
x11()
Histogram(data = slope,x = slope,breaks = 20)

x11()
Histogram(data = curvature,
          x = curvature,
          breaks = 30)

x11()
Histogram(data = curvature,
          x = curvature,
          density = T)

## CONFIGURACIÓN COMO SERIE TEMPORAL
slope <- ts(slope$slope,
            start = c(1962,01),
            frequency = 12)

curvature <- ts(curvature$curvature,
                start = c(1962,01),
                frequency = 12)

head(slope)
head(curvature)

## VISUALIZACIÓN
autoplot(slope) + 
  ggtitle("Slope") + ylab("")

ggAcf(slope) + 
  ggtitle("FAC")

?window

## ACORTAR LA VENTANA TEMPORAL
slope_training <- window(slope, 
                         start = c(1962,01), 
                         end = c(1977,01))

curvature_training <- window(curvature, 
                             start = c(1962,01), 
                             end = c(1977,01))

g1 <- autoplot(slope_training) + 
  ggtitle("Slope",subtitle = "1962-1976") + 
  ylab("")

g2 <- autoplot(curvature_training) + 
  ggtitle("Curvature",subtitle = "1962-1976") + 
  ylab("")

gridExtra::grid.arrange(g1, g2, ncol=2)

## FAC 

h1 <- ggAcf(curvature_training,type = "correlation",lag.max = 30) + 
  ggtitle("FAC", subtitle = "Curvature")

h2 <- ggAcf(curvature_training,type = "partial") + 
  ggtitle("FACP", subtitle = "Curvature")

gridExtra::grid.arrange(h1, h2, ncol=2)

ggAcf(slope_training,type = "correlation",plot = F)
ggAcf(slope_training,type = "partial",plot = F)

## ESTIMACIÓN

training <- curvature_training
auto.arima(training, trace = T)

model1 <- arima(training,
                order = c(1,0,0),
                method = "ML", 
                include.mean = T)

model2 <- arima(training,
                order = c(2,0,0),
                method = "ML", 
                include.mean = T)

model3 <- arima(training,
                order = c(1,0,1),
                method = "ML", 
                include.mean = T)

model4 <- arima(training,
                order = c(2,0,1),
                method = "ML", 
                include.mean = T)

model5 <- arima(training,
                order = c(2,0,2),
                method = "ML", 
                include.mean = T)

model6 <- arima(training,
                order = c(2,0,3),
                method = "ML", 
                include.mean = T)

model7 <- arima(training, 
                order = c(13, 0, 0), 
                fixed = c(NA, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NA, NA))

model8 <- arima(training, 
                order = c(18, 0, 0), 
                fixed = c(NA, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NA, NA))

model9 <- arima(training, 
                order = c(18, 0, 0), 
                fixed = c(NA, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NA, 0, 0, 0, 0, NA, NA))

summary(model1)

summary(model2)

summary(model3)

summary(model4)

summary(model5)

summary(model6)

summary(model7)

summary(model8)

summary(model9)

AIC(model1,model2,model3,model4, model5,model6,model7,model8,model9)
BIC(model1,model2,model3,model4, model5,model6,model7,model8,model9)

# ggAcf(resid(model1), type = "correlation")  ## con función "arma"
# ggAcf(resid(model1), type = "partial")

x11()
tsdiag(model1)

x11()
tsdiag(model2)

x11()
tsdiag(model3)

x11()
tsdiag(model4)

x11()
tsdiag(model5)

# FAC de los Residuos
ggAcf(resid(model5), type = "correlation")

ggAcf(resid(model5), type = "partial")

AIC_Matrix(training,
           p.order = 3,
           q.order = 3)

auto.arima(training,trace = T, stepwise = F)
auto.arima(training,trace = T, stepwise = T)

coeftest(model4)

confint(model4)

library(FitAR)
boxresult <- LjungBoxTest(model4$residuals,
                          k = 2,
                          StartLag = 1)

plot(boxresult[,3],
     main = "Ljung-Box Q Test", 
     ylab = "P-values", 
     xlab = "Lag")

qqnorm(model4$residuals)
qqline(model4$residuals)

jarque.bera.test(resid(model1)[150:181])
jarque.bera.test(resid(model2)[150:181])
jarque.bera.test(resid(model3)[150:181])
jarque.bera.test(resid(model4)[150:181])
jarque.bera.test(resid(model5)[150:181])
jarque.bera.test(resid(model6)[150:181])
jarque.bera.test(resid(model7)[150:181])
jarque.bera.test(resid(model8)[150:181])
jarque.bera.test(resid(model9)[150:181])

Box.test(resid(model8)[150:181],lag = 4,type = "Ljung-Box",fitdf = 2)
Box.test(resid(model8)[150:181],lag = 6,type = "Ljung-Box",fitdf = 2)
Box.test(resid(model8)[150:181],lag = 8,type = "Ljung-Box",fitdf = 2)

## Predicciones

predict(model1,n.ahead = 5)

fcast <- forecast(model1, h=5)
plot(fcast)
