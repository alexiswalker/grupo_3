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

path = "D:/OneDrive - Facultad de Cs Económicas - UBA/Docencia/Posgrado/Austral/Análisis de Series Temporales/2021/Rosario/Práctica/Clase 8/"
setwd(path)

dir()

#####################
## CARGAR PAQUETES ##
#####################

suppressPackageStartupMessages({
  library(fpp2)
  library(ggplot2)
  library(forecast)
})

## CARGAR DATOS
data(lynx)

## GRÁFICO DE LA SERIE Annual Canadian Lynx Trappings (1821-1934)
autoplot(lynx) + 
  xlab("Year") + 
  ylab("# of Lynx Trapped") + 
  ggtitle("Annual Canadian Lynx Trappings (1821-1934)")

## GRÁFICO DE LA SERIE, FAC Y FACP
ggtsdisplay(lynx)

## ENTRENAR MODELO NNAR
nn1 = nnetar(y = lynx, 
             p = 4, 
             P = 0,
             size = 2)

## VER ESTRUCTURA DE LOS DATOS
print(nn1)

## CHEQUEAR ESTRUCTURA DE LOS RESIDUOS DEL MODELO
checkresiduals(nn1)

## FORECASTING PARA 10 PASOS ADELANTE
fc1 = forecast(nn1,h=10)

autoplot(fc1) + 
  xlab("Year") + 
  ylab("# of Lynx Trapped") + 
  ggtitle("Ann. Lynx Trappings with 10-year Forecast")

## FORECASTING CON INTERVALOS DE PREDICCIÓN
fc1.PI = forecast(nn1,h=10, PI = T)
autoplot(fc1.PI) + 
  xlab("Year") + 
  ylab("# of Lynx Trapped") + 
  ggtitle("Ann. Lynx Trappings with 10-year Forecast")

## VISTA DE LOS INTERVALOS PREDICHOS
fc1.PI

## GRAFICO DE LA SERIE ORIGINAL Y EL MODELO AJUSTADO
autoplot(lynx) + 
  autolayer(fitted(nn1))

## CONSULTAR CANTIDAD DE DATOS DE LA SERIE
length(lynx)    ## 114 DATOS

## SEPARAR EN CONJUNTO DE ENTRENAMIENTO Y DE TESTING
lynx.train = head(lynx,100)   ## TOMAR LOS PRIMEROS 100
lynx.test = tail(lynx,14)     ## TOMAR LOS ÚLTIMOS 14

## ENTRENAR EL MODELO CON LOS DATOS DEL CONJUNTO DE ENTRENAMIENTO
nn1 = nnetar(lynx.train,
             p = 4,
             P = 0,
             size = 2)

## FORECASTING PARA LOS 14 PASOS ADELANTE DE LA SERIE
fc1 = forecast(nn1,h=14)

## EVALUAR LA PERFORMANCE DEL MODELO CON LOS DATOS DE TESTING
accuracy(fc1,lynx.test)

## GRAFICAR LA SERIE Y LAS PREDICCIONES SOBRE EL CONJUNTO DE DATOS DE TESTING
autoplot(fc1) + 
  autolayer(lynx.test,series="Actual")

## GRAFICAR LOS DATOS REALES DEL CONJUNTO DE TESTING CON LAS PREDICCIONES 
autoplot(lynx.test) + 
  autolayer(fc1,series="Forecast")

## OTRO EJEMPLO: U.S. Monthly Retail Clothing Sales

## CARGAR DATOS
Cloth = read.csv("http://course1.winona.edu/bdeppa/FIN%20335/Datasets/US%20Clothing%20Sales%20(millions%20of%20dollars%20-%201992%20to%20present).csv",header=T)
head(Cloth)

## CONFIGURAR LOS DATOS COMO SERIE DE TIEMPO
ClothSales = ts(Cloth$Clothing,start=1992,frequency=12)

## SELECCIONAR LOS DATOS DESDE 2010 EN ADELANTE
ClothSales = window(ClothSales,start=2010)

## GRAFICAR LA SERIE DESDE 2010 EN ADELANTE
autoplot(ClothSales) + 
  xlab("Year") + 
  ylab("Millions $") + 
  ggtitle("Monthly Retail Clothing Sales (January 2010-January 2018")

## ANALIZAR LA ESTRUCTURA DE LA SERIE (FAC y FACP)
ggtsdisplay(ClothSales)

## CONSTRUIR EL MODELO
nn1 = nnetar(ClothSales,
             p = 3, 
             P = 1,
             size = 3)

## EVALUAR RESULTADOS DEL MODELO
print(nn1)

## CHEQUEAR LOS RESIDUOS DEL MODELO
checkresiduals(nn1)

## FORECASTING POR INTERVALOS DE LA SERIE PARA LOS 24 PASOS ADELANTE
fc = forecast(nn1,h=24,PI=T)

## GRAFICAR LAS PREDICCIONES DE LA SERIE
autoplot(fc) + 
  xlab("Year") + 
  ylab("Millions $") + 
  ggtitle("Clothing Sales with Forecast from NNAR(3,1,3)")

## CONSULTAR LA CANTIDAD DE DATOS DE LA SERIE
length(ClothSales)

## SEPARAR EN CONJUNTO DE ENTRENAMIENTO Y DE TESTING
Cloth.train = head(ClothSales,
                   length(ClothSales)-12)   ## MENOS LOS ÃšLTIMOS 12 PARA ENTRENAR

Cloth.test = tail(ClothSales,12)            ## LOS ÃšLTIMOS 12 PARA TESTEAR

## ENTRENAR EL MODELO CON LOS DATOS DE ENTRENAMIENTO 
nn1 = nnetar(Cloth.train,
             p = 4,
             P = 2,
             size = 3,
             repeats = 30)

## FORECASTING CON EL MODELO ENTRENADO PARA LOS SIGUIENTES 12 PASOS ADELANTE
fc = forecast(nn1,h = 12)

## GRAFICO DE LAS PREDICCIONES CON EL MODELO ENTRENADO CON EL SOLAPAMIENTO DE LOS DATOS DE TESTING
autoplot(fc) + 
  autolayer(Cloth.test,series="Actual")

## EVALUAR LA PERFORMANCE DEL MODELO CON LOS DATOS DE TESTING
accuracy(fc,Cloth.test)

## COMPARACIÓN CON OTRAS METODOLOGÍAS

## HW: HOLT-WINTERS SEASONAL METHOD
Cloth.hw = hw(Cloth.train,h=12)
accuracy(Cloth.hw,Cloth.test)

## ETS: ERROR TREND SEASONAL METHOD
Cloth.ets = ets(Cloth.train)
fc.ets = forecast(Cloth.ets,h=12)
accuracy(fc.ets,Cloth.test)

## ARIMA: ENTRENAR MODELO, FORECASTING PARA LOS PRÃ“XIMOS 12 PASOS Y EVALUACIÃ“N DE PERFORMANCE
Cloth.ARIMA = auto.arima(Cloth.train,
                         approximation = F,
                         stepwise = F)

fc.ARIMA = forecast(Cloth.ARIMA,h=12)
accuracy(fc.ARIMA,Cloth.test)

## ENTRENAR EL MODELO PARA CONSTRUIR INTERVALOS DE PREDICCIÃ“N
nn1 = nnetar(ClothSales,
             p = 4,
             P = 2,
             size = 3)

## CREACIÓN DE UNA MATRIZ DE 10 SERIES CON 24 MESES
sim <- ts(matrix(0, nrow=24L, ncol=10L),
          start = end(ClothSales)[1L],
          frequency=12)

## COMPLETAR LA MATRIZ SIMULANDO VALORES CON EL MODELO ENTRENADO
for(i in seq(10)){
  sim[,i] = simulate(nn1,nsim = 24L)
}

## GRAFICAR LAS 10 SERIES SIMULADAS CON EL MODELO
autoplot(ClothSales) + 
  autolayer(sim) + 
  ylab("Millions $") + 
  xlab("Year") + 
  ggtitle("US Monthly Retail Clothing Sales with Simulations")

## FORECASTING CON INTERVALOS DE PREDICCIÓN PARA LOS PROXIMOS 24 PASOS
fc = forecast(nn1,PI=T,h=24)
print(fc)

## GRAFICO DE LAS PREDICCIONES DE LA SERIE
autoplot(fc) + 
  xlab("Year") + 
  ylab("Millions $") + 
  ggtitle("NNAR(4,2,3) Forecasts for US Monthly Clothing Sales")