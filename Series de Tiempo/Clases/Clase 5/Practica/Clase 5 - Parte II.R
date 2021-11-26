##########################################################
#             ANALISIS DE SERIES TEMPORALES              #
#	            MAESTRIA EN CIENCIA DE DATOS               #
#                FACULTAD DE INGENIERIA                  #
#                 UNIVERSIDAD AUSTRAL                    #
##########################################################

## Asignatura: ANALISIS DE SERIES TEMPORALES
## Docente: Rodrigo Del Rosso

rm(list = ls())

## .rs.restartR()

options(scipen = 999)

################################
####### SETEO DE CARPETA #######
################################

path = "D:/OneDrive - Facultad de Cs Económicas - UBA/Docencia/Posgrado/Austral/Análisis de Series Temporales/2021/Rosario/Práctica/Clase 4/"
setwd(path)

################################################################################
## Ejemplos basados en los siguientes links                                   ##
## https://datascienceplus.com/structural-changes-in-global-warming/          ##
## https://www.r-bloggers.com/2017/10/arima-models-and-intervention-analysis/ ##
################################################################################

#####################
## CARGAR PAQUETES ##
#####################

suppressPackageStartupMessages({
  library(ggplot2)
  library(forecast)
  library(astsa)
  library(lmtest)
  library(fUnitRoots)
  library(FitARMA)
  library(strucchange)
  library(reshape)
  library(Rmisc)
  library(fBasics)
})

####################################
## EJEMPLO 1 - TEMPERATURA GLOBAL ##
####################################

data("globtemp")
globtemp

## informa la desviación (en grados centrígrados) de la 
## temperatura media global terrestre-oceánica [1951-1980]

## ESTADÍSTICAS BÁSICAS - MEDIDAS
summary(globtemp)

## VISUALIZACIÓN DE LA SERIE
autoplot(globtemp) + 
  ggtitle("Temperatura Media Global", subtitle = "Desviación") + 
  ylab("Grados centigrados") + theme_bw()


tt <- 1:length(globtemp)
fit <- ts(loess(globtemp ~ tt, span = 0.2)$fitted, start = 1880, frequency = 1)
plot(globtemp, type='l')
lines(fit, col = 4)
grid()

plot(density(globtemp), main = "globtemp density plot")

## TEST DE RAÃZ UNITARIA
urdftest_lag = floor(12*(length(globtemp)/100)^0.25)
library(urca)
ur.df(globtemp, lags = urdftest_lag, type = "trend")
summary(ur.df(globtemp, lags = urdftest_lag, type = "trend"))

## la prueba de Dickey Fuller está sesgada hacia el no rechazo de la hipótesis nula

## la prueba KPSS tendrá la hipótesis de estacionariedad de tendencia como nula 
## es decir, tendencia determinista con residuos estacionarios

ur.kpss(globtemp, lags = "long", type = "tau")
summary(ur.kpss(globtemp, lags = "long", type = "tau"))

## Rechazamos la hipótesis de estacionariedad de tendencia

## fUnitRoots::urdfTest(globtemp, lags = urdftest_lag, type = c("ct"), doplot = FALSE)
## fUnitRoots::urkpssTest(globtemp, type = c("tau"), lags = c("long"),  doplot = FALSE)

## DETECCIÓN DE CAMBIOS ESTRUCTURALES

# cambios estructurales de nivel
# tendencia a cambios estructurales
# cambios estructurales de ajuste polinomial
# cambios estructurales del modelo autorregresivo

##############################
## Level Structural Changes ##
##      globtemp ~ 1        ##
##############################

summary(lm(globtemp ~ 1))
coeftest(lm(globtemp ~ 1))  ## COEFICIENTE NO SIGNIFICATIVO

tail(globtemp) ## TERMINA EN 2015

globtemp_win <- window(globtemp, end = 2000)
lev_fit <- lm(globtemp_win ~ 1)
summary(lev_fit)
coeftest(lev_fit)  ## COEFICIENTE SIGNIFICATIVO

## VISUALIZACIÓN DE LA SERIE CON EL AJUSTE DE LA RECTA
plot(globtemp_win)
lines(ts(fitted(lev_fit), start = 1880, frequency = 1), col = 4)

## DETERMINACIÓN DE LOS PUNTOS DE CORTE
?breakpoints
globtemp_brk <- breakpoints(globtemp_win ~ 1, h = 0.1)
summary(globtemp_brk)

## El valor mínimo de BIC se alcanza para m = 5

## VISUALIZACIÓN DE LOS PUNTOS DE CORTE
plot(globtemp_brk)

## VISUALIZACIÓN DE LA SERIE CON LOS PUNTOS DE CORTE E IC
plot(globtemp_win)
lines(fitted(globtemp_brk, breaks = 5), col = 4)
lines(confint(globtemp_brk, breaks = 5))

## FECHAS DE CORTE
breakdates(globtemp_brk, breaks = 5)

## VALOR DE LOS COEFICIENTES DE CORTE
coef(globtemp_brk, breaks = 5)

##############################
## Trend Structural Changes ##
##       globtemp ~ tt      ##
##############################

## REGRESIÓN DE LA TENDENCIA
l <- length(globtemp)
tt <- 1:l      ## línea de tiempo
trend_fit <- lm(globtemp ~ tt)
summary(trend_fit)

## VISUALIZACIÓN DE LA SERIE Y LA TENDENCIA
plot(globtemp)
lines(ts(fitted(trend_fit), start = 1880, frequency = 1), col = 4)

## DETERMINACIÓN DE LOS PUNTOS DE CORTE
globtemp_brk <- breakpoints(globtemp ~ tt, h = 0.1)
summary(globtemp_brk)

## valor mínimo de BIC se alcanza para m = 4

## VISUALIZACIÓN DE LOS PUNTOS DE CORTE
plot(globtemp_brk)

x11()
plot(globtemp)
lines(fitted(globtemp_brk, breaks = 4), col = 4)
lines(confint(globtemp_brk, breaks = 4))

## FECHAS DE CORTE
breakdates(globtemp_brk, breaks = 4)

## VALOR DE LOS COEFICIENTES DE CORTE
coef(globtemp_brk, breaks = 4)

#######################################
## Polinomial Fit Structural Changes ## 
##      globtemp ~ tt + I(tt^2)      ##
#######################################

## ESTIMAR MODELO DE REGRESIÓN POLINÓMICA
pol_fit <- lm(globtemp ~ tt + I(tt^2))
summary(pol_fit)

## VISUALIZACIÓN
plot(globtemp, type = 'l')
lines(ts(fitted(pol_fit), start = 1880, frequency = 1), col = 4)

## DETERMINACIÓN DE LOS PUNTOS DE CORTE
globtemp_brk <- breakpoints(globtemp ~ tt + I(tt^2), data = globtemp, h = 0.1)
summary(globtemp_brk)

## VISUALIZACIÓN DE PUNTOS DE CORTE
plot(globtemp_brk)

plot(globtemp)
lines(fitted(globtemp_brk, breaks = 2), col = 4)
lines(confint(globtemp_brk, breaks = 2))

## DETERMINACIÓN DE LOS PUNTOS DE CORTE
breakdates(globtemp_brk, breaks = 2)

## VALOR DE LOS COEFICIENTES ESTIMADOS
coef(globtemp_brk, breaks = 2)

##############################################
## Auto-regressive Model Structural Changes ##
##############################################

## GENERACIÓN DE LA PRIMERA DIFERENCIA PARA HACERLA ESTACIONARIA
diff_globtemp <- diff(globtemp) - mean(diff(globtemp))
plot(diff_globtemp, type = 'l')
grid()

## TEST DE RAÍZ UNITARIA PARA PONER A PRUEBA DICHA CONJETURA
urdftest_lag = floor(12*(length(diff_globtemp)/100)^0.25)
summary(ur.df(diff_globtemp, lags = urdftest_lag, type = "trend"))

## a un nivel de significancia del 5%, rechazamos la hipÃ³tesis nula de raÃ­z unitaria

summary(ur.kpss(diff_globtemp, lags = "long", type = "mu"))

## Con base en las estadísticas de prueba y los valores críticos informados, 
## no podemos rechazar la hipótesis nula de estacionariedad de nivel

## urdfTest(diff_globtemp, lags = urdftest_lag, type = c("nc"), doplot = FALSE)
## urkpssTest(diff_globtemp, type = c("mu"), lags = c("long"),  doplot = FALSE)

## AJUSTAR A UN MODELO DE REGRESIÓN LINEAL PARA AJUSTAR EL VALOR ACTUAL

lag_1 <- lag(diff_globtemp, -1)
lag_2 <- lag(diff_globtemp, -2)
globtemp_df <- ts.intersect(dd0 = diff_globtemp, dd1 = lag_1, dd2 = lag_2)
summary(lm(dd0 ~ dd1 + dd2 - 1, data = globtemp_df))

## DETERMINACIÓN DE LOS PUNTOS DE CORTE
dd_brk <- breakpoints(dd0 ~ dd1 + dd2 - 1, data = globtemp_df, h = 0.1)
summary(dd_brk)

## VISUALIZACIÓN DE LOS PUNTOS DE CORTE
plot(dd_brk)

## el BIC es mínimo para m = 0

## IDENTIFICACIÓN DE CAMBIOS ESTRUCTURALES MEDIANTE PRUEBA F
globtemp_Fstats <- Fstats(dd0 ~ dd1 + dd2 - 1, data = globtemp_df,  from = 0.05, to = 0.95)
plot(globtemp_Fstats)  # No se puede detectar ningÃºn cruce de lÃ­mites

sctest(globtemp_Fstats, type = "supF")  
# El valor p confirma que no hay un punto de corte significativo

###################################
## EJEMPLO 2 - ARBUTHNOT DATASET ##
###################################

## Contiene información de nacimientos anuales masculinos y femeninos en LondrÃ©s de 1639 a 1710

url <- "https://www.openintro.org/stat/data/arbuthnot.csv"
abhutondot <- read.csv(url, header=TRUE)
nrow(abhutondot)

## VIEW DEL DATASET
head(abhutondot)

## RECONSTRUCCIÓN DEL DATASET POR LA VARIABLE "year"
abhutondot_rs <- melt(abhutondot, id = c("year"))
head(abhutondot_rs)
tail(abhutondot_rs)

## VISUALIZACIÓN
ggplot(data = abhutondot_rs, aes(x = year)) + 
  geom_line(aes(y = value, colour = variable)) +
  scale_colour_manual(values = c("blue", "red")) + 
  ggtitle("Nacimientos Anuales por GÃ©nero en LondrÃ©s", subtitle = "PerÃ­odo 1639 a 1710") + 
  ylab("")

## TEST DE WELCH DE DIFERENCIA DE MEDIAS POBLACIONALES
t.test(value ~ variable, data = abhutondot_rs)

## ESTADÍSTICAS DESCRIPTIVAS DE AMBAS VARIABLES
fBasics::basicStats(abhutondot[-1])

p1 <- ggplot(data = abhutondot_rs, aes(x = variable, y = value)) + geom_boxplot()
p2 <- ggplot(data = abhutondot, aes(boys)) + geom_density()
p3 <- ggplot(data = abhutondot, aes(girls)) + geom_density()
multiplot(p1, p2, p3, cols = 3)

## SERIE DE TIEMPO QUE SE ANALIZARÁ
excess_frac <- (abhutondot$boys - abhutondot$girls)/abhutondot$girls
excess_ts <- ts(excess_frac, frequency = 1, start = abhutondot$year[1])
autoplot(excess_ts)

## TEST DE RAÍZ UNITARIA
urdftest_lag = floor(12*(length(excess_ts)/100)^0.25)
summary(ur.df(excess_ts, type = "none", lags = urdftest_lag))
summary(ur.df(excess_ts, type = "drift", lags = urdftest_lag))

## urdfTest(excess_ts, type = "nc", lags = urdftest_lag, doplot = FALSE)
## urdfTest(excess_ts, type = "c", lags = urdftest_lag, doplot = FALSE)

## FAC Y FACP
par(mfrow=c(1,2))
acf(excess_ts)
pacf(excess_ts)

###########################
## CAMBIOS ESTRUCTURALES ##
###########################

## REGRESIÓN CONTRA UNA CONSTANTE
summary(lm(excess_ts ~ 1))

(break_point <- breakpoints(excess_ts ~ 1))
plot(break_point)
summary(break_point)

## VISUALIZACIÓN DEL PUNTO DE CORTE
plot(excess_ts)
lines(fitted(break_point, breaks = 1), col = 4)
lines(confint(break_point, breaks = 1))

## VALOR DE LA VARIABLE EN LOS PUNTOS DE CORTE
fitted(break_point)[1]
fitted(break_point)[length(excess_ts)]
## INDICA QUE LA PROPORCIÓN DE GÉNERO CAMBIO DE M A F

## TEST DE DIFERENCIA DE MEDIAS EN DISTINTAS VENTANAS TEMPORALES MARCADAS POR EL QUIEBRE
break_date <- breakdates(break_point)
win_1 <- window(excess_ts, end = break_date)
win_2 <- window(excess_ts, start = break_date + 1)
t.test(win_1, win_2)

## se rechaza la hipótesis nula de que la verdadera diferencia es igual a cero

##################
## ARIMA MODELS ##
##################

g1 = ggAcf(excess_ts, type = "correlation") + 
  ggtitle("FAC")
g2 = ggAcf(excess_ts, type = "partial") + 
  ggtitle("FACP")
gridExtra::grid.arrange(g1,g2,ncol = 2)

## MODELO 1
model_1 <- auto.arima(excess_ts, stepwise = FALSE, trace = TRUE)
summary(model_1)
coeftest(model_1)

## MODELO 2
model_2 <- Arima(excess_ts, order = c(1,0,0), 
                 seasonal = list(order = c(0,0,1), period = 10), 
                 include.mean = TRUE)
summary(model_2)
coeftest(model_2)

## MODELO 3
model_3 <- Arima(excess_ts, order = c(1,0,0), 
                 seasonal = list(order = c(1,0,0), period = 10), 
                 include.mean = TRUE)
summary(model_3)
coeftest(model_3)

## MODELO 4
level <- c(rep(0, break_point$breakpoints), 
           rep(1, length(excess_ts) - break_point$breakpoints))
model_4 <- Arima(excess_ts, order = c(0,0,0), 
                 seasonal = list(order = c(0,0,1), period = 10), 
                 xreg = level, include.mean = TRUE)
summary(model_4)
coeftest(model_4)

## MODELO 5
model_5 <- Arima(excess_ts, order = c(1,0,0), 
                 seasonal = list(order = c(0,0,1), period=10), 
                 xreg = level, include.mean = TRUE)
summary(model_5)
coeftest(model_5)

## MODELO 6
model_6 <- Arima(excess_ts, 
                 order = c(1,0,0), 
                 xreg = level, 
                 include.mean = TRUE)
summary(model_6)
coeftest(model_6)

## ANALISIS DE RESIDUOS (DIAGNOSTICO DE MODELOS)
checkresiduals(model_1)
LjungBoxTest(residuals(model_1), k = 2, lag.max = 20)
sarima(excess_ts, p = 1, d = 1, q = 1)


checkresiduals(model_2)
LjungBoxTest(residuals(model_2), k = 2, lag.max = 20)
sarima(excess_ts, p = 1, d = 0, q = 0, P = 0, D = 0, Q = 1, S = 10)

checkresiduals(model_3)
LjungBoxTest(residuals(model_3), k = 2, lag.max = 20)
sarima(excess_ts, p = 1, d = 0, q = 0, P = 1, D = 0, Q = 0, S = 10)
tseries::jarque.bera.test(residuals(model_3))
nortest::ad.test(residuals(model_3))

checkresiduals(model_4)
LjungBoxTest(residuals(model_4), k = 1, lag.max = 20)
sarima(excess_ts, p = 0, d = 0, q = 0, P = 0, D = 0, Q = 1, S = 10, xreg = level)
tseries::jarque.bera.test(residuals(model_4))

checkresiduals(model_6)
LjungBoxTest(residuals(model_6), k = 1, lag.max = 20)
sarima(excess_ts, p = 1, d = 0, q = 0, xreg = level)


df <- data.frame(col_1_res = c(model_1$aic, model_2$aic, model_3$aic, model_4$aic, model_6$aic),
                 col_2_res = c(model_1$aicc, model_2$aicc, model_3$aicc, model_4$aicc, model_6$aicc),
                 col_3_res = c(model_1$bic, model_2$bic, model_3$bic, model_4$bic, model_6$bic))
colnames(df) <- c("AIC", "AICc", "BIC")
rownames(df) <- c("ARIMA(1,1,1)", 
                  "ARIMA(1,0,0)(0,0,1)[10]", 
                  "ARIMA(1,0,0)(1,0,0)[10]", 
                  "ARIMA(0,0,0)(0,0,1)[10] with level shift", 
                  "ARIMA(1,0,0) with level shift")
df

## FORECASTING
h_fut <- 5
plot(forecast(model_4, 
              h = h_fut, 
              xreg = rep(1, h_fut)))

## ANÁLISIS HISTÓRICO - GUERRAS CÍVILES
abhutondot.ts <- ts(abhutondot$boys + abhutondot$girls, frequency = 1 , 
                    start = abhutondot$year[1])
autoplot(abhutondot.ts)

## CAMBIO ESTRUCTURAL - REGRESIÓN CONTRA CONSTANTE
summary(lm(abhutondot.ts ~ 1))

(break_point <- breakpoints(abhutondot.ts ~ 1))
plot(break_point)
summary(break_point)

plot(abhutondot.ts)
fitted.ts <- fitted(break_point, breaks = 3)
lines(fitted.ts, col = 4)
lines(confint(break_point, breaks = 3))

unique(as.integer(fitted.ts))
breakdates(break_point, breaks = 3)

fitted.ts <- fitted(break_point, breaks = 3)
autoplot(fitted.ts)

## CAMBIO ESTRUCTURAL - MODELO ARIMA
abhutondot_xreg <- Arima(abhutondot.ts, order = c(0,1,1), xreg = fitted.ts, include.mean = TRUE)
summary(abhutondot_xreg)
coeftest(abhutondot_xreg)

checkresiduals(abhutondot_xreg)
LjungBoxTest(residuals(abhutondot_xreg), k=1, lag.max=20)
sarima(abhutondot.ts, p=0, d=1, q=1, xreg = fitted.ts)
