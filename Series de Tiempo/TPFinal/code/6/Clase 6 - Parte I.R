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

path = "D:/OneDrive - Facultad de Cs Económicas - UBA/Docencia/Posgrado/Austral/Análisis de Series Temporales/2021/Rosario/Práctica/Clase 7/"
setwd(path)
getwd()     ## verifico si me modificó la ruta
dir()

#####################
## CARGAR PAQUETES ##
#####################

suppressPackageStartupMessages({
  library(vars)
  library(urca)
  library(lmtest)
  library(forecast)
  library(ggplot2)
  library(reshape2)
})

#########################
####### EJEMPLO 1 #######
#########################

## EJEMPLO CON DATOS SIMULADOS

set.seed(123)

t <- 200 # Cantidad de observaciones de la Serie de Tiempo
k <- 2   # Cantidad de variables endógenas
p <- 2   # Cantidad de rezagos

# GENERACIÓN DE MATRIZ CON COEFICIENTES

A.1 <- matrix(c(-.3, .6, -.4, .5), k) # Matriz de coeficientes del lag 1
A.2 <- matrix(c(-.1, -.2, .1, .05), k) # Matriz de coeficientes del lag 2

## MATRIZ DE LOS COEFICIENTES DEL MODELO
A <- cbind(A.1, A.2)

# GENERAR SERIES
series <- matrix(data = 0, nrow = k, ncol = t + 2 * p) # Series con Ceros

for (i in (p + 1):(t + 2*p)){ # e ~ N(0,0.5)
  series[, i] <- A.1%*%series[,i-1] + A.2%*%series[,i-2] + rnorm(k, 0, .5)
}

## CONVERTIR AL FORMATO SERIES DE TIEMPO
series <- ts(t(series[, -(1:p)]))

data.class(series)

## RENOMBRAR LAS VARIABLES
colnames <- c("Variable 1", "Variable 2")

## PRIMERAS OBSERVACIONES
head(series)

## GRAFICAR LAS SERIES
plot.ts(series)

## ESTIMAR EL MODELO
var_model <- VAR(y = series, 
                 p = 2, 
                 type = "none")

data.class(var_model)

var_model$varresult

var.aic <- VAR(series, 
               type = "none", 
               lag.max = 5, 
               ic = "AIC")

summary(var.aic)

# EXTRAER LOS COEFICIENTES, DESVIOS ESTÁNDAR A PARTIR DEL OBJETO VAR
est_coefs <- coef(var.aic)

# EXTRAER LOS COEFICIENTES, DESVIOS ESTÁNDAR DE LAS VARIABLES DEPENDIENTES
# COMBINAR LOS RESULTADOS EN UNA MATRIZ
est_coefs <- rbind(est_coefs[[1]][, 1], est_coefs[[2]][, 1]) 

# IMPRIMIR LAS ESTIMACIONES REDONDEADAS
round(est_coefs, 2)

# CALCULAR EL IMPULSO RESPUESTA
ir.1 <- irf(var_model, 
            impulse = "Series.1", 
            response = "Series.2", 
            n.ahead = 20, 
            ortho = FALSE)

# GRAFICAR LA FUNCIÓN IMPULSO RESPUESTA (IRF)
plot(ir.1)

# CALCULAR EL IMPULSO RESPUESTA
ir.2 <- irf(var_model,
            impulse = "Series.1",
            response="Series.2",
            n.ahead = 20,ortho = FALSE,
            cumulative = TRUE)

# GRAFICO
plot(ir.2)

#########################
####### EJEMPLO 2 #######
#########################

# Crear el objeto mex_var en base a los datos en el archivo base_var_inflacion.csv
mex_var <- read.csv("base_var_inflacion.csv", 
                    header=T)
mex_var$M2

attach(mex_var)
M2
## detach(mex_var)

# Una vez creado el objeto de trabajo, se procede a dar formato de series de tiempo a la base de datos.

# Para la oferta monetaria
tm2 <- ts(mex_var[,1], start = 2000, freq = 12)
tm2
class(tm2)

# Para el índice de precios 
tp <- ts(mex_var[,2], start=2000, freq=12) 

# A estas nuevas variables se les aplica logaritmo.

# Para la oferta monetaria
ltm2 <- log(tm2)

# Para el índice de precios.
ltp <- log(tp)

# Para graficar las series
ts.plot(ltp, ltm2, 
        col = c("blue", "red"), 
        main = "Evolución del logaritmo de M2 y IPC")

# Para aplicar la prueba ADF sin constante ni tendencia
library(urca)
adf1_ltp <- summary(ur.df(ltp, lags=1))
adf1_ltp 

# Para aplicar la prueba ADF con constante o con deriva.
adf2_ltp <- summary(ur.df(ltp, type="drift", lags=1))
adf2_ltp

# Para aplicar la prueba ADF con tendencia.
adf3_ltp<-summary(ur.df(ltp, type="trend", lags=1))
adf3_ltp

# Para que las variables sean estacionarias se procede generar las segundas diferencias de las variables.

# Para generar la primera diferencia del logaritmo del Ã­ndice de precios
dltp <- diff(ltp)

autoplot(dltp) + 
  ggtitle("Logaritmo del índice de Precios", 
          subtitle = "Primera Diferencia") + 
  ylab("En %")

ggAcf(ltp, type = "correlation", lag.max = 50)
ggAcf(dltp, type = "correlation", lag.max = 50)


# Para generar la segunda diferencia del logaritmo del Ã­ndice de precios
d2ltp <- diff(dltp)

autoplot(d2ltp) + 
  ggtitle("Logaritmo del índice de Precios", 
          subtitle = "Segunda Diferencia") + 
  ylab("En %")

# Para generar la primera diferencia del logaritmo de la oferta monetaria
dltm2 <- diff(ltm2)

# Para generar la segunda diferencia del logaritmo de la oferta monetaria
d2ltm2 <- diff(dltm2)

## Dickey Fuller para m2


## Evaluar la presencia de 1 raíz unitaria
summary(ur.df(ltm2, lags=1))  ## None
summary(ur.df(ltm2, lags=1,type = "drift"))  ## Drift
summary(ur.df(ltm2, lags=1,type = "trend"))  ## Trend

## Evaluar la presencia de 2 raíces unitarias
summary(ur.df(ltp, lags=2))  ## None


# Para graficar las variables se utiliza el siguiente comando. 
ts.plot(dltp, dltm2, col=c("blue", "red"))
ts.plot(d2ltp, d2ltm2, col=c("blue", "red"))

#Para analizar la causalidad de granger en las variables se utilizan los siguientes comandos 

# La causalidad de la oferta monetaria hacia los precios.
grangertest(d2ltp ~ d2ltm2, order = 1)

# La causalidad de los precios hacia la oferta monetaria. 
grangertest(d2ltm2 ~ d2ltp, order = 1)

#Para la creación del var se procede a crear un nuevo objeto con las variables estacionarias y transformadas en series de tiempo. 
mex_var2 <- data.frame(d2ltm2,d2ltp)

#Para la identificación del VAR. 
VARselect(mex_var2, lag.max = 12)

#Para la estimación del VAR.
var1 <- VAR(mex_var2,p = 11)
var1

#Para saber si el VAR satisface las condiciones de estabilidad se utiliza el siguiente comando.
summary(var1)

## Para obtener el grafico de la variable observado vs la estimada 
## del Modelo VAR se utiliza la siguiente función

x11()
plot(var1)

# Para realizar las pruebas de especificación del VAR, se utilizan los siguientes comandos.

# Para realizar la prueba de autocorrelación se usa el siguiente comando.
seriala <- serial.test(x = var1, 
                       lags.pt = 11, 
                       type = "PT.asymptotic")
seriala$serial  

#Para la prueba de normalidad
normalidad <- normality.test(var1)
normalidad$jb.mul
normalidad$jb.mul 

#Para la prueba de heteroscedasticidad
arch1 <- arch.test(var1, lags.multi=11)
arch1$arch.mul 

#Para analizar el impulso respuesta de la variable estudiada y observar su trayectoria.
#Para el impulso respuesta del índice de precios.
var1_irfltp <- irf(var1, response="d2ltp", n.ahead=8, boot=TRUE)
var1_irfltp 

# Para graficar el impulso respuesta

plot(var1_irfltp)

# Para el impulso respuesta de la oferta monetaria

var1_irfltm2 <- irf(var1, response="d2ltm2", n.ahead=5, boot=TRUE)

var1_irfltm2

#Para graficar el impulso respuesta
plot(var1_irfltm2) 

## Para el análisis de la descomposición de varianza de las variables, 
## se usan los siguientes comandos,

# Para el índice de precios

var1_fevd_d2ltp<-fevd(var1, n.ahead=50)$d2ltp
var1_fevd_d2ltp 

# Para la oferta monetaria

var1_fevd_d2ltm2 <- fevd(var1, n.ahead=50)$d2ltm2
var1_fevd_d2ltm2

# Forecasting

par(mar = c(1,1,1,1))
plot(predict(var1, 
             n.ahead = 12, 
             ci = 0.95), 
     xlab = "Tiempo", 
     ylab = "En %")