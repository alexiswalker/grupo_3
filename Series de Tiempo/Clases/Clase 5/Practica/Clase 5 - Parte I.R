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
  library(quantmod)
})

## European quarterly retail trade

autoplot(euretail) + 
  ylab("Retail index") + 
  xlab("Year")

euretail %>% 
  diff(lag=4) %>% 
  ggtsdisplay()

euretail %>% 
  diff(lag=4) %>% 
  diff() %>% 
  ggtsdisplay()

euretail %>%
  Arima(order=c(0,1,1), seasonal=c(0,1,1)) %>%
  residuals() %>% ggtsdisplay()

fit3 <- Arima(euretail, order=c(0,1,3), seasonal=c(0,1,1))
checkresiduals(fit3)

fit3 %>% 
  forecast(h=12) %>% 
  autoplot()

auto.arima(euretail)

## Corticosteroid drug sales in Australia

lh02 <- log(h02)
cbind("H02 sales (million scripts)" = h02,
      "Log H02 sales"=lh02) %>%
  autoplot(facets=TRUE) + xlab("Year") + ylab("")

lh02 %>% diff(lag=12) %>%
  ggtsdisplay(xlab="Year",
              main="Seasonally differenced H02 scripts")

(fit <- Arima(h02, order=c(3,0,1), seasonal=c(0,1,2),
              lambda=0))

checkresiduals(fit, lag=36)

h02 %>%
  Arima(order=c(3,0,1), seasonal=c(0,1,2), lambda=0) %>%
  forecast() %>%
  autoplot() +
  ylab("H02 sales (million scripts)") + xlab("Year")



# Load package
library(quantmod)

# Create a series_name object
series_name <- "UNRATE"   # To find the series name, go to the FRED website and search for "United States civilian unemployment rate".

# Load the data using getSymbols
UR <- getSymbols(Symbols = series_name, src = "FRED", auto.assign = FALSE)
head(UR)
tail(UR)

# Load package
library(forecast) 
library(ggplot2)

UR_ts <- ts(UR[, c("UNRATE")], start = c(1948, 1), frequency = 12)

autoplot(UR_ts)

# Plot differenced data
autoplot(diff(UR_ts))

# Plot the ACF of the differenced murder rate
ggAcf(diff(UR_ts))

# Find value for lamda to transform data and stablize variance
BoxCox.lambda(UR_ts)

# Fit a seasonal ARIMA model 
fit1 <- auto.arima(UR_ts)
fit2 <- auto.arima(UR_ts, stepwise = FALSE) 

# Summarize the fitted model
summary(fit1)
summary(fit2)

# # Check that both models have white noise residuals
checkresiduals(fit1)

checkresiduals(fit2)

fit1 %>% forecast(h = 24) %>% autoplot()

fit2 %>% forecast(h = 24) %>% autoplot() + ylab("Number of Startups")
