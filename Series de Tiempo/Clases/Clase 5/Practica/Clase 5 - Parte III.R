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
  library(ggplot2)
  library(tidyverse)
  library(forecast)
  library(yardstick)
  library(garma)
})

# Gray, H, N Zhang, and W Woodward. 1989. "On Generalized Fractional Processes." Journal of Time Series Analysis 10 (3): 233-57.
# Gray, H, N Zhang, and W Woodward. 1994. "On Generalized Fractional Processes - a Correction." Journal of Time Series Analysis 15 (5): 561-62.

data(NileMin,package = 'longmemo')
# Solo estableceremos el año de inicio correcto, con fines de visualización.

NileMin <- ts(as.numeric(NileMin),
              start = 622,
              frequency = 1)

ggtsdisplay(NileMin,
            lag.max=350, 
            main='NileMin time series.', 
            theme=theme_bw())


## OTRO DATASET
data(sunspot.year)

sunspots <- ts(sunspot.year[49:224],
               start = 1749,
               end = 1924)
ggtsdisplay(sunspots,
            lag.max = 350, 
            main='Sunspot Counts', 
            theme = theme_bw())

sunspots_arima_mdl <- arima(sunspots, order=c(9,0,0),method='CSS')

summary(sunspots_arima_mdl)

# Como en Gray et al. (1989) ajustamos a un modelo GARMA(1,0)
sunspots_garma_mdl <- garma(sunspots, 
                            order = c(1,0,0),
                            k = 1,
                            method = 'CSS')
summary(sunspots_garma_mdl)

(sunspots_garma_mdl <- garma(sunspots, order = c(9, 0, 0), k = 1))

compare_df <- data.frame(yr=1925:1935,
                         Actuals=as.numeric(sunspot.year[225:235]),
                         ARIMA=forecast(sunspots_arima_mdl,h=11)$mean,
                         GARMA=forecast(sunspots_garma_mdl,h=11)$mean)

cat(sprintf('\n\nEvaluación de los datos del conjunto de pruebas de 1925 a 1936.\n\nARIMA RMSE: %.2f\nGARMA RMSE: %.2f\n',
            yardstick::rmse(compare_df,Actuals,ARIMA)$.estimate,
            yardstick::rmse(compare_df,Actuals,GARMA)$.estimate))

arima_df <- data.frame(yr=1925:1935, sunspots=forecast(sunspots_arima_mdl,h=11)$mean,grp='AR(11) forecasts')
garma_df <- data.frame(yr=1925:1935, sunspots=forecast(sunspots_garma_mdl,h=11)$mean,grp='GARMA(1),k=1 forecasts')
actuals_df <- data.frame(yr=1749:1935,sunspots=as.numeric(sunspot.year[49:235]),grp='Actuals')
df <- rbind(actuals_df,garma_df,arima_df)

ggplot(df,aes(x=yr,y=sunspots,color=grp)) + geom_line() +
  scale_color_manual(name='',values=c('Actuals'='darkgray','AR(11) forecasts'='darkgreen','GARMA(1),k=1 forecasts'='blue')) +
  xlab('') + ylab('Cantidad de Sunspots') +
  geom_vline(xintercept=1924,color='red',linetype='dashed',size=0.3) +
  theme_bw() +
  ggtitle('Pronósticos de Sunspots: comparación de ARIMA (9,0,0) y GARMA (9,0), k = 1')

