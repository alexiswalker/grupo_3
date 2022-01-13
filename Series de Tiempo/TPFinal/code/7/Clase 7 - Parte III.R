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

## CARGAR LIBRERÍA
suppressPackageStartupMessages({
  library(ggplot2)
  library(timetk)
  library(dplyr)
  library(forecast)
  library(keras)
})

## VIEW SOBRE LOS PRIMEROS DATOS DEL DATASET
head(economics)

serie = economics$unemploy

## DETERMINAR LOS FACTORES DE ESCALAMIENTO: MEDIA Y DESVIO DE LA SERIE
scale_factors <- c(mean(serie), sd(serie))
print(scale_factors)

## SELECCIONAR VARIABLE DE INTERÉS Y ESCALARLA
scaled_train <- economics %>% 
  select(unemploy) %>%
  mutate(unemploy = (unemploy - scale_factors[1]) / scale_factors[2])

## DEFINIR HORIZONTE DE PREDICCIÓN
prediction <- 12
lag <- prediction

## DEFINIR COMO UNA MATRIZ AL CONJUNTO DE DATOS ESCALADOS
scaled_train <- as.matrix(scaled_train)

## RETRASAR LOS DATOS 11 VECES Y ORGANIZARLOS COMO COLUMNAS
x_train_data <- t(sapply(
  1:(length(scaled_train) - lag - prediction + 1),
  function(x) scaled_train[x:(x + lag - 1), 1]
))

## TRANSFORMAR EN FORMATO ARRAY
x_train_arr <- array(
  data = as.numeric(unlist(x_train_data)),
  dim = c(nrow(x_train_data),lag,1)
)

## SIMILAR TRANSFORMACIÓN PARA LOS VALORES DE Y
y_train_data <- t(sapply(
  (1 + lag):(length(scaled_train) - prediction + 1),
  function(x) scaled_train[x:(x + prediction - 1)]
))

y_train_arr <- array(
  data = as.numeric(unlist(y_train_data)),
  dim = c(nrow(y_train_data),prediction,1)
)

## PREPARAR DATOS PARA LA PREDICCIÓN
x_test <- economics$unemploy[(nrow(scaled_train) - prediction + 1):nrow(scaled_train)]

## ESCALAR Y TRANSFORMAR
x_test_scaled <- (x_test - scale_factors[1])/scale_factors[2]

## LA MATRIZ TIENE UNA MUESTRA Y SE PRETENDE UNA PREDICCIÃ“N PARA LOS PRÃ“XIMOS 12 MESES
x_pred_arr <- array(
  data = x_test_scaled,
  dim = c(1,lag,1)
)

## CREAR EL MODELO
lstm_model <- keras_model_sequential()

lstm_model %>%
  layer_lstm(units = 50, # size of the layer
             batch_input_shape = c(1, 12, 1), # batch size, timesteps, features
             return_sequences = TRUE,
             stateful = TRUE) %>%
  # fraction of the units to drop for the linear transformation of the inputs
  layer_dropout(rate = 0.5) %>%
  layer_lstm(units = 50,
             return_sequences = TRUE,
             stateful = TRUE) %>%
  layer_dropout(rate = 0.5) %>%
  time_distributed(keras::layer_dense(units = 1))

## COMPILAR EL MODELO
lstm_model %>%
  compile(loss = 'mae', 
          optimizer = 'adam', 
          metrics = 'accuracy')

## MIRAR LA ESTRUCTURA DEL MODELO
summary(lstm_model)

## FIT EL MODELO
lstm_model %>% fit(
  x = x_train_arr,
  y = y_train_arr,
  batch_size = 1,
  epochs = 20,
  verbose = 0,
  shuffle = TRUE #,
  # callbacks = callback_early_stopping(patience = 2, monitor = 'acc'),
  # validation_split = 0.3
)

## FORECASTING CON EL MODELO LSTM
lstm_forecast <- lstm_model %>%
  predict(x_pred_arr, batch_size = 1) %>%
  .[, , 1]

## SE REESCALA LAS PREDICCIONES A LOS NIVELES ORIGINALES
lstm_forecast <- lstm_forecast * scale_factors[2] + scale_factors[1]

## PREDICCIÓN CON LOS DATOS DE ENTRENAMIENTO
fitted <- predict(lstm_model, x_train_arr, batch_size = 1) %>%
  .[, , 1]

## SE NECESITA TRANSFORMAR LOS DATOS PARA OBTENER SOLO UNA PREDICCIÃ“N POR CADA FECHA
if(dim(fitted)[2] > 1){
  fit <- c(fitted[, 1], fitted[dim(fitted)[1], 2:dim(fitted)[2]])
} else {
  fit <- fitted[, 1]
}

## ADICIONALMENTE SE REESCALAN LOS DATOS
fitted <- fit * scale_factors[2] + scale_factors[1]
length(fitted)

## ESPECIFICAR LOS PRIMEROS VALORES DE PRONOSTICO COMO NO DISPONIBLES
fitted <- c(rep(NA, lag), fitted)

## CONFIGURAR LAS PREDICCIONES COMO SERIE TEMPORAL
lstm_forecast <- tk_ts(lstm_forecast,
                       start = c(2015, 5),
                       end = c(2016, 4),
                       frequency = 12)

## VISUALIZAR LAS PREDICCIONES
lstm_forecast

## CONFIGURAR LOS DATOS ORIGINALES COMO SERIE TEMPORAL
input_ts <- tk_ts(economics$unemploy, 
                  start = c(1967, 7), 
                  end = c(2015, 4), 
                  frequency = 12)

## DEFINIR EL OBJETO DE PRONOSTICO
forecast_list <- list(
  model = NULL,
  method = "LSTM",
  mean = lstm_forecast,
  x = input_ts,
  fitted = fitted,
  residuals = as.numeric(input_ts) - as.numeric(fitted)
)

class(forecast_list) <- "forecast"

## GRAFICAR EL OBJETO 
autoplot(forecast_list)

## PREDICCIÓN DE LSTM CON REGRESORES
reg <- 100 * runif(nrow(economics))

scale_factors_reg <- list(mean = mean(reg),sd = sd(reg))

scaled_reg <- (reg - scale_factors_reg$mean)/scale_factors_reg$sd

## ADICIONALMENTE 12 VALORES PARA EL FORECAST
scaled_reg_prediction <- (reg[(length(reg) -12): length(reg)] - 
                            scale_factors_reg$mean) /scale_factors_reg$sd

## COMBINAR DATOS DE ENTRENAMIENTO CON REGRESORES
x_train <- cbind(scaled_train, scaled_reg)
x_train_data <- list()

## TRANSFORMAR LOS DATOS DENTRO DE LAS COLUMNAS REZAGADAS
for(i in 1:ncol(x_train)){
  x_train_data[[i]] <- t(sapply(
    1:(length(x_train[, i]) - lag - prediction + 1),
    function(x) x_train[x:(x + lag - 1), i]
  ))
}

x_train_arr <- array(
  data = as.numeric(unlist(x_train_data)),
  dim = c(
    nrow(x_train_data[[1]]),
    lag,
    2
  )
)

## COMBINAR LOS DATOS CON LOS REGRESORES
x_test_data <- c(x_test_scaled, scaled_reg_prediction)

## TRANSFORMAR A TENSOR
x_pred_arr <- array(
  data = x_test_data,
  dim = c(1,lag,2))

## VISUALIZAR EL ARRAY CON LAS PREDICCIONES
x_pred_arr