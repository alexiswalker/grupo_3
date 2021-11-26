##########################################################
#AQUI VEO DOS BASES DE DATOS REALES   ####################
#                                     ####################
# 1) LA BASE DEL COVID 19             ####################
# 2) BASE DEL IPC                     ####################
##########################################################

##########################################################
################## PREPARO TRABAJO    ####################
##########################################################

suppressPackageStartupMessages({
  library(tseries)
  library(forecast)
  library(astsa)
  library(PerformanceAnalytics)
  library(quantmod)
  library(Quandl)
  library(ggplot2)
  library(gridExtra)
  library(dygraphs)
  library(PASWR2)
  library(pastecs)
  library(psych)
  library(lessR)
  library(readxl)
  })

##########################################################
# CASO 1                                              ####
# COVID-19                                            ####
##########################################################

COVID <- read.csv("casos_covid19.csv")
head(COVID)
class(COVID)

# Configurar la/s variables de inter?s como serie/s de tiempo" 
inds <- seq(as.Date("2020-03-02"), as.Date("2021-06-15"), by = "day")

COVID_TS <- ts(COVID$nuevos_casos_caba,     # random data
                    start = c(2020, as.numeric(format(inds[1], "%j"))),
                    frequency = 365)

# confirmo que sea serie de tiempo
class(COVID_TS)

###GRAFICOS  

#grafico 1
autoplot(COVID_TS) +
  ggtitle("COVID-19 en CABA") +
  ylab("casos nuevos por dia") +
  xlab("tiempo")

#grafico 2
plot(COVID_TS, col = "red", main = "Evolucion COVID-19 en CABA", ylab = "casos nuevos diarios", xlab ="Tiempo", lwd=2, type="l", pch=10)

# GRAFICOS DE ACF
acf(COVID_TS, lag.max =20, plot =F)
acf(COVID_TS, lag.max =20, plot =T)
ggAcf(COVID_TS)

u1 = autoplot(COVID_TS) + ggtitle("Casos confirmados Covid-19", subtitle = "") + ylab("")
u2 = ggAcf(COVID_TS) + ggtitle("Casos confirmados Covid-19", subtitle = "FAC")
grid.arrange(u1,u2)

# Analizamos 50 Lag's
ggAcf(COVID_TS,lag.max = 50)

# 
plot(COVID_TS)
abline(reg=lm(COVID_TS~time(COVID_TS)))

# Atencion = este grafico no tiene sentido con este dataset!, solo es para mostrar que = por mas simple que sea el analisis siempre hay que adaptarlo a nuestro dataset
boxplot(COVID_TS~cycle(COVID_TS))
# 

# TRANSFORMAMOS LA SERIE ORIGINAL

# transformacion DIF de la serie
dif_COVID_TS=diff(COVID_TS)

# transformacion logaritmica de la serie
log_COVID_TS=log(COVID_TS)
# transformacion diferenciada de la serie con transformacion logaritmica
log_dif_COVID_TS=diff(log_COVID_TS)


# ploteo de COVID solo diff
plot(dif_COVID_TS)
abline(reg=lm(dif_COVID_TS~time(dif_COVID_TS)))

# ploteo de COVID solo log
plot(log_COVID_TS)
abline(reg=lm(log_COVID_TS~time(log_COVID_TS)))

# ploteo de COVID con log y dif
plot(log_dif_COVID_TS)
abline(reg=lm(log_dif_COVID_TS~time(log_dif_COVID_TS)))

##########################################################
# CASO 2                                              ####
# IPC                                                 ####
##########################################################

IPC <- read.csv("Indice_precios.csv")
head(IPC)
class(IPC)

IPC_TS = ts(IPC$IPC, 
              frequency = 12, 
              start = c(2017,01))

# vemos que el Data ahora es time series
class(IPC_TS)

# COMPONENTES DE LA SERIE DE TIEMPO
#descomposicion general
plot(decompose(IPC_TS)) 


# 
plot(aggregate(IPC_TS,FUN = mean))


# 
boxplot(IPC_TS~cycle(IPC_TS))


# 
plot(IPC_TS)
abline(reg=lm(IPC_TS~time(IPC_TS)))


# vemos que no es estacionaria. 

# Aplicamos unas transformaciones iniciales. solo para introducirles, pero se van a ver mas a fondo en el desarrollo de las clases.

# transformacion DIF de la serie
dif_IPC_TS=diff(IPC_TS)
# transformacion logaritmica de la serie
log_IPC_TS=log(IPC_TS)
# transformacion diferenciada de la serie con transformacion logaritmica
log_dif_IPC_TS=diff(log_IPC_TS)

# ploteo de IPC solo diff
plot(dif_IPC_TS)
abline(reg=lm(dif_IPC_TS~time(dif_IPC_TS)))

# ploteo de IPC solo log
plot(log_IPC_TS)
abline(reg=lm(log_IPC_TS~time(log_IPC_TS)))

# ploteo de IPC con log y dif
plot(log_dif_IPC_TS)
abline(reg=lm(log_dif_IPC_TS~time(log_dif_IPC_TS)))


# recuerden que estas transformaciones ( tanto en el caso 1, como en el caso 2) son mero ejemplos generales sin sentido teorico. A lo largo de las clases veremos las transformaciones apropiadas segun los datasets usados
