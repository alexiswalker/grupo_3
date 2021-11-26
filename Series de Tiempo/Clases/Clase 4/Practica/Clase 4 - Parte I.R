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
})


# Graficar la serie "a10"
autoplot(a10)

# Probar con 4 valores de lambda de la TransformaciÃ³n de Box-Cox
a10 %>% 
  BoxCox(lambda = 0.0) %>% 
  autoplot()

a10 %>% 
  BoxCox(lambda = 0.1) %>% 
  autoplot()

a10 %>% 
  BoxCox(lambda = 0.2) %>% 
  autoplot()

a10 %>% 
  BoxCox(lambda = 0.3) %>% 
  autoplot()

# Comparar con el valor provisto por la función BoxCox.lambda()
BoxCox.lambda(a10)

a10 %>% 
  BoxCox(lambda = BoxCox.lambda(a10)) %>% 
  autoplot()

# Cargar datos para Evaluar Normalidad

datos <- read.table("orig.txt", header = T)
head(datos)

jarque.bera.test(datos$plasma)

summary(powerTransform(datos$plasma))

lambda = powerTransform(datos$plasma)

datos$plasma_transforma <- datos$plasma ^ lambda$lambda

jarque.bera.test(datos$plasma_transforma)

## SERIES NO ESTACIONARIAS ##

datos2 <- read.table("crestcolgate.dat", 
                     header = TRUE)

## CUOTA DE MERCADO DE COLGATE EN ESPAÑA ##
mkt_share_colgate = ts(datos2$X0.424,
                       start = c(1958, 01), 
                       end = c(1963,04), 
                       frequency = 52)

dif_mkt_share_colgate = diff(mkt_share_colgate)

g1 = autoplot(mkt_share_colgate) + 
  ggtitle("Market Share de Colgate", subtitle = "Cuota Semanal")  + 
  ylab("En %")

g2 = autoplot(dif_mkt_share_colgate) + 
  ggtitle("Market Share de Colgate", subtitle = "1era Diferencia")  + 
  ylab("")

grid.arrange(g1,g2)

## RANDOM WALK

serie1 = NULL
phi = 1
y0 = 10
n = 200
i = 1
for(i in 1:n){
  if(i == 1){
    serie1[i] = y0
  } else if(i > 1) {
    serie1[i] = phi * serie1[i-1] + rnorm(1)  
  }
}

serie2 = NULL
phi = 1
y0 = 10
c = 1
n = 200
i = 1
for(i in 1:n){
  if(i == 1){
    serie2[i] = y0
  } else if(i > 1) {
    serie2[i] = c + phi * serie2[i-1] + rnorm(1)  
  }
}

serie1 = ts(serie1, frequency = 1)
serie2 = ts(serie2, frequency = 1)

w1 = autoplot(serie1) + 
  ggtitle("Random Walk", subtitle = "Sin Drift")  + 
  ylab("")

w2 = autoplot(serie2) + 
  ggtitle("Random Walk", subtitle = "Con Drift")  + 
  ylab("")

grid.arrange(w1,w2)

w1 = autoplot(serie1) + 
  ggtitle("Random Walk", subtitle = "Sin Drift")  + 
  ylab("")

w3 = ggAcf(serie1, type = "correlation") + 
  ggtitle("FAC - Random Walk", subtitle = "Sin Drift")  + 
  ylab("")

grid.arrange(w1,w3)

## ARIMA ##

serie4 = arima.sim(list(order = c(1,1,1), ar = 0.40,ma = 0.85), n = 300)
autoplot(serie4)

p1 = autoplot(serie4) + 
  ggtitle("ARIMA(1,1,1)")  + 
  ylab("")

p2 = ggAcf(serie4, type = "correlation") + 
  ggtitle("FAC", subtitle = "ARIMA(1,1,1)")  + 
  ylab("")

grid.arrange(p1,p2)

## OTRO EJEMPLO ##

data(USeconomic)
View(USeconomic)

a1 = autoplot(log(M1)) + 
  ggtitle("Logaritmo del M1")  + 
  ylab("")

a2 = autoplot(GNP) + 
  ggtitle("Gross National Product")  + 
  ylab("")

a3 = autoplot(rs) + 
  ggtitle("Rate Short")  + 
  ylab("")

a4 = autoplot(rl) + 
  ggtitle("Rate Long")  + 
  ylab("")

grid.arrange(a1,a2,a3,a4)

b1 = ggAcf(log(M1), type = "correlation") + 
  ggtitle("FAC", subtitle = "Logaritmo de M1")  + 
  ylab("")

b2 = ggAcf(GNP, type = "correlation") + 
  ggtitle("FAC", subtitle = "Gross Product National")  + 
  ylab("")

b3 = ggAcf(rs, type = "correlation") + 
  ggtitle("FAC", subtitle = "Rate Short")  + 
  ylab("")

b4 = ggAcf(rl, type = "correlation") + 
  ggtitle("FAC", subtitle = "Rate Long")  + 
  ylab("")

grid.arrange(b1,b2,b3,b4)

modelo1 <- arma(log(M1),
                order=c(1,0,0))
modelo1

summary(modelo1)

m1.diff <- diff(log(M1))
m1.diff

par(mar = c(1,1,1,1))
par(mfrow=c(3,2))
plot(log(M1),col="blue");plot(m1.diff,col="red")
acf(log(M1),col="blue");acf(m1.diff,col="red")
pacf(log(M1),col="blue");pacf(m1.diff,col="red")

## EstimaciÃ³n de la serie diferenciada ##

modelo2 <- arma(m1.diff,order = c(1,0,0))
modelo2
summary(modelo2)

#############################
## EJEMPLO - PIB DE MEXICO ##
#############################

load("BDatos_Integracion.RData")
View(BDatos)

plot(BDatos$PIB_Mex)
lines(BDatos$PIB_Mex)

summary(BDatos)

attach(BDatos)
## detach(BDatos)

PIB_Mex <- ts(BDatos$PIB_Mex,
              frequency=4,
              start=1993)

lpib_mex <- log(PIB_Mex)
d_lpib_mex <- diff(lpib_mex)
d_lpib_mex2 <- diff(lpib_mex,2)

v1 = autoplot(PIB_Mex) + 
  ggtitle("PIB", subtitle = "México") + 
  ylab("")

v2 = autoplot(lpib_mex) + 
  ggtitle("Logaritmo PIB", subtitle = "México") +
  ylab("")

v3 = autoplot(d_lpib_mex) + 
  ggtitle("1era Diferencia", subtitle = " Logaritmo PIB México") +
  ylab("")

v4 = autoplot(d_lpib_mex2) + 
  ggtitle("2da Diferencia", subtitle = " Logaritmo PIB México") +
  ylab("")

grid.arrange(v1,v2,v3,v4)

##################################
## ANÁLISIS DE RAÍCES UNITARIAS ##
##################################

## WHITE NOISE
TT <- 100
wn <- rnorm(TT)  # white noise
autoplot(ts(wn)) + ggtitle("Ruido Blanco") + ylab("")

## PRIMERA FORMA DE TESTEAR PRESENCIA DE RAÍCES UNITARIAS
tseries::adf.test(wn)

tseries::adf.test(wn, k = 0)

## WHITE NOISE CON INTERCEPTO
intercept <- 1
wnt <- wn + 1:TT + intercept
autoplot(ts(wnt)) + ggtitle("Ruido Blanco", subtitle = "Con Drift") + ylab("")

tseries::adf.test(wnt)

## RANDOM WALK
rw <- cumsum(rnorm(TT))
autoplot(ts(rw)) + ggtitle("Random Walk") + ylab("")

tseries::adf.test(rw)

tseries::adf.test(rw, k = 0)

j = adf.test(rw, k = 0)
j$p.value

## OTRA FUNCIÓN "ur.df" PROVIENE DEL PACKAGE "urca"
wn <- rnorm(TT)
test <- ur.df(wn, type = "trend", lags = 0)
j = summary(test)

data.class(j)

## LEER UN OBJETO "S4" - "sumurca"
j@teststat
j@cval
rbind(j@teststat,j@cval)


## OTRO EJEMPLO
data("USMacroG")
View(USMacroG)

unemp_us <- USMacroG[2:204,9]

autoplot(ts(unemp_us)) + 
  ggtitle("Tasa de Desempleo", subtitle = "USA") + 
  ylab("En %")

unemp_sum1 <- summary(ur.df(unemp_us))
unemp_sum2 <- summary(ur.df(unemp_us, type = "none", lags = 1))
unemp_sum3 <- summary(ur.df(unemp_us, type = "none", lags = 2))
unemp_sum4 <- summary(ur.df(log(unemp_us), type = "none", lags = 0))
unemp_sum5 <- summary(ur.df(log(unemp_us), type = "trend", lags = 0))
unemp_sum6 <- summary(ur.df(log(unemp_us), type = "drift", lags = 0))
unemp_sum7 <- summary(ur.df(diff(unemp_us), type = "none", lags = 0))
unemp_sum8 <- summary(ur.df(diff(unemp_us), type = "none", lags = 1))
unemp_sum9 <- summary(ur.df(diff(unemp_us), type = "none", lags = 2))

inflation_us <- USMacroG[2:204,11]
autoplot(ts(inflation_us)) + 
  ggtitle("Tasa de InflaciÃ³n", subtitle = "USA") + 
  ylab("En %")

inf_sum1 <- summary(ur.df(inflation_us, type = "none", lags = 0))
inf_sum2 <- summary(ur.df(inflation_us, type = "none", lags = 1))
inf_sum3 <- summary(ur.df(inflation_us, type = "none", lags = 2))

money_supply <- USMacroG[,7]

autoplot(ts(money_supply)) + 
  ggtitle("Money Supply", subtitle = "USA") + 
  ylab("")

autoplot(diff(money_supply))

m1_sum1 <- summary(ur.df(money_supply))
m1_sum2 <- summary(ur.df(money_supply, type = "trend", lags = 0))
m1_sum3 <- summary(ur.df(money_supply, type = "trend", lags = 1))
m1_sum4 <- summary(ur.df(money_supply, type = "trend", lags = 2))
m1_sum5 <- summary(ur.df(diff(money_supply), type = "trend", lags = 0))

adf.test(unemp_us)
adf.test(inflation_us)
adf.test(money_supply)

## RUIDO BLANCO
x <- rnorm(1000)  # Sin raíz unitaria, ¿porque?
autoplot(ts(x))
adf.test(x)

## RANDOM WALK (integrar un Ruido Blanco es un RW)
y <- diffinv(x)   # Contiene una raíz unitaria
autoplot(ts(y))
adf.test(y, k = 0)

## CUANTAS VECES HABRÍA QUE DIFERENCIAR LA SERIE PARA CONVERTIRLA EN ESTACIONARIA
ndiffs(unemp_us)
ndiffs(inflation_us)
ndiffs(money_supply)

## PROBAMOS CON LAS SERIES DEL LIBRO DE DANIEL PEÑA
ndiffs(mkt_share_colgate)
ndiffs(madrid_index)
ndiffs(pob_may16)

adf.test(mkt_share_colgate, k = 0)
summary(ur.df(mkt_share_colgate, lags = 0))

# nsdiffs(serie)  ## Para Estacional

## COMPARATIVA DE 4 IMPLEMENTACIONES DE ADF
set.seed(1)
x <- rnorm(50, 0, 3)
autoplot(ts(x))

tseries::adf.test(x, k = 10)

CADFtest(x, max.lag.y = 10, type = "trend")

urca::ur.df(x, lags = 10, type = "trend")

fUnitRoots::adfTest(x, lags = 10, type = "ct")

## PARA PIB DE MEXICO
trend.df <- ur.df(PIB_Mex,type="trend",lags=4,selectlags=c("AIC"))
drift.df <- ur.df(PIB_Mex,type="drift",lags=4,selectlags=c("AIC"))
none.df <- ur.df(PIB_Mex,type="none",lags=4,selectlags=c("AIC"))

summary(none.df)
summary(drift.df)
summary(trend.df)

## EL OBJETO ES S4 PARA RETRIVEAR CON EL SIMBOLO @
summary(test)@teststat
summary(test)@cval

## ¿SE ANIMAN A CREAR UNA FUNCIÓN PARA HACER EL TEST? ##

## Para determinar el orden de integración de las variables, 
## se aplican las pruebas Dickey Fuller Aumentado con sus tres posibilidades, 
## 1) tendencia y constante; 
## 2) con constante y, 
## 3) sin constante ni tendencia, 
## a la primera diferencia del logaritmo del PIB

trend.df <- ur.df(d_lpib_mex,type="trend",lags=1,selectlags=c("AIC"))
drift.df <- ur.df(d_lpib_mex,type="drift",lags=1,selectlags=c("AIC"))
none.df <- ur.df(d_lpib_mex,type="none",lags=1,selectlags=c("AIC"))

summary(trend.df)
summary(drift.df)
summary(none.df)