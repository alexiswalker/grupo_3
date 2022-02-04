##########################################################
#             ANALISIS DE SERIES TEMPORALES              #
#	            MAESTRIA EN CIENCIA DE DATOS               #
#                FACULTAD DE INGENIERIA                  #
#                 UNIVERSIDAD AUSTRAL                    #
##########################################################

## Asignatura: ANALISIS DE SERIES TEMPORALES
## Docente: Rodrigo Del Rosso

## Limpiar consola y resetear sesión

rm(list = ls())
.rs.restartR()

## Cargar librerías

suppressPackageStartupMessages({
  library(tidyverse)
  library(tidymodels)
  library(modeltime)
  library(anomalize) 
  library(modeltime.resample)
  library(tibbletime)
  library(tseries)
  library(rsample)
  library(lubridate)
  library(timetk)
  library(gt)
  library(plotly)
})

## Instalar librería desde github
# devtools::install_github("rafzamb/sknifedatar")
library(sknifedatar)

################################################
## Ajuste de un modelo a una serie individual ##
################################################

## Cargar datos

## Flujo diario de circulación vehicular

df_avellaneda <- sknifedatar::data_avellaneda %>% 
  mutate(date = as.Date(date))

df_avellaneda %>%
  head(5) %>% 
  gt() %>% 
  tab_header(title = 'Flujo vehicular diario', 
             subtitle = 'Estación Avellaneda') %>% 
  tab_footnote(
    footnote = "Fuente: GCBA",
    locations = cells_column_labels(columns = vars(value)))

## Visualización de la serie

df_avellaneda %>% 
  plot_time_series(.date_var = date, 
                   .value = value, 
                   .interactive = FALSE, 
                   .line_size = 0.15) 

## División en training y testing set

df_avellaneda_model <- df_avellaneda %>%
  filter(date < '2020-01-01') 

splits_transporte <- initial_time_split(
  data = df_avellaneda_model, 
  prop = 0.8)

splits_transporte

## Visualización de la partición de los datos

splits_transporte %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE,
                           .title = "Estacion Avellaneda - Partición Train / Test") +
  theme(strip.text = element_blank())

## Modelo - Definición de Especificación

prophet_reg(mode = 'regression')

## Modelo - Definición de Algoritmo desde donde se corre

prophet_reg(mode='regression') %>%
  set_engine('prophet')

## Se ajusta el modelo a los datos de entrenamiento

m_prophet_transporte <- prophet_reg(mode='regression') %>%
  set_engine('prophet') %>% 
  fit(value~date, data = training(splits_transporte))

## Modelo entrenado

m_prophet_transporte

## Forecast sobre datos de testing

calibrate_transporte <- m_prophet_transporte %>% 
  modeltime_table() %>% 
  modeltime_calibrate(new_data=testing(splits_transporte)) 

calibrate_transporte

## Predicciones con los datos desconocidos

forecast_transporte <- calibrate_transporte %>% 
  modeltime_forecast(
    new_data    = testing(splits_transporte),
    actual_data = df_avellaneda_model
  ) 

## Visualización

forecast_transporte %>% 
  plot_modeltime_forecast(
    .legend_max_width = 30, 
    .interactive      = FALSE,
    .conf_interval_alpha = 0.2, 
    .line_size=0.2
  ) 

## Evaluación del modelo

calibrate_transporte %>% 
  modeltime_accuracy() %>% 
  gt() %>% 
  tab_header('Métricas de evaluación')

## Ingeniería de variables

receta_transporte <- recipe(value ~ ., data = training(splits_transporte)) %>%
  step_date(date, features = c("month", "quarter", "year"), ordinal=TRUE) %>% 
  step_lag(value, lag = 1)

receta_transporte %>%
  prep() %>% 
  juice() %>% 
  head(3) %>% 
  gt() %>%
  tab_header('Datos luego de añadir variables de fecha y 1 rezago')

## Imputación de valores nulos

receta_transporte <- receta_transporte %>%
  step_ts_impute(all_numeric(), period = 365)

receta_transporte %>% 
  prep() %>% 
  juice() %>% 
  head(3) %>% 
  gt() %>%
  tab_header('Datos luego de imputar de valores nulos en series temporales')

## La forma de utilizar esta receta en un modelo es la siguiente:

# 1. Se genera un workflow
# 2. Se añade la receta
# 3. Se añade el modelo
# 4. Se entrena

## Modelos

m_prophet_boost_transporte <- workflow() %>% 
  add_recipe(receta_transporte) %>% 
  add_model(
    prophet_boost(mode='regression') %>%
      set_engine("prophet_xgboost")
  )

m_prophet_boost_transporte <- m_prophet_boost_transporte %>% 
  fit(data = training(splits_transporte))

m_prophet_boost_transporte %>% 
  modeltime_table() %>% 
  modeltime_calibrate(new_data=testing(splits_transporte)) %>% 
  modeltime_accuracy() %>% 
  gt() %>% 
  tab_header('Métricas de evaluación')

## Receta 1
## Para modelos en los cuales NO ES necesario que 
## todos los datos sean numéricos

receta_transporte_1 <- recipe(value ~ date, 
                              data = training(splits_transporte)) %>%
  step_timeseries_signature(date) %>% 
  step_rm(contains("iso"), 
          contains("minute"), 
          contains("hour"),
          contains("am.pm"), 
          contains("xts"), 
          contains("second"),
          date_index.num, 
          date_wday, 
          date_month)

receta_transporte_1 %>% 
  prep() %>% 
  juice() %>% 
  head(2) %>% 
  gt()

## Receta 2
## Para modelos en los cuales ES necesario que 
## todos los datos sean numéricos

receta_transporte_2 <- receta_transporte_1 %>% 
  step_mutate(date = as.numeric(date)) %>% 
  step_normalize(all_numeric(), -all_outcomes()) %>% 
  step_dummy(date_month.lbl, date_wday.lbl)

receta_transporte_2 %>% 
  prep() %>% 
  juice() %>% 
  head(2) %>% 
  gt()

##############################################
## Múltiples modelos en una serie de tiempo ##
##############################################

## add in para buscar especificaciones de los modelos
library(parsnip)
parsnip_addin()

# Modelo Auto-ARIMA
m_autoarima_transporte <- arima_reg() %>% 
  set_engine('auto_arima') %>%  
  fit(value ~ date, data = training(splits_transporte))

# Modelo exponential smoothing
m_exp_smoothing_transporte <- exp_smoothing() %>% 
  set_engine('ets') %>% 
  fit(value ~ date, data = training(splits_transporte))

# Modelo prophet boosted
m_prophet_boost_transporte <- workflow() %>% 
  add_recipe(receta_transporte_1) %>% 
  add_model(prophet_boost(mode='regression') %>% set_engine("prophet_xgboost")) %>% 
  fit(data = training(splits_transporte))

# Modelo NNetar
m_nnetar_transporte <- workflow() %>%
  add_recipe(receta_transporte_1) %>% 
  add_model(nnetar_reg() %>% set_engine("nnetar")) %>% 
  fit(training(splits_transporte))

# Modelo MARS
m_mars_transporte <- workflow() %>%
  add_recipe(receta_transporte_2) %>%
  add_model(mars(mode = "regression") %>% 
              set_engine("earth")) %>%
  fit(training(splits_transporte))

## Incorporar todos los modelos en una tabla

modelos_transporte <- modeltime_table(
  m_autoarima_transporte,
  m_exp_smoothing_transporte,
  m_prophet_boost_transporte,
  m_mars_transporte,
  m_nnetar_transporte
)

calibration_table_transporte <- modelos_transporte %>%
  modeltime_calibrate(new_data = testing(splits_transporte))

## FUNCIÓN PARA CREAR UNA TABLA DE EVALUACIÓN DE MODELOS

accuracy_table <- function(.accuracy, 
                           .subtitle=NULL,
                           .color1='#c5cde0', 
                           .color2='#6274a3',
                           .round_num=0.01){
  .accuracy %>%
    select(-.type) %>%
    mutate(across(where(is.numeric), round, 2)) %>%
    gt(rowname_col = c(".model_id")) %>%
    tab_header(title = 'Evaluación de modelos',
               subtitle = .subtitle) %>%
    cols_label(`.model_desc` = 'Modelo') %>%
    data_color(columns = vars(mae),
               colors = scales::col_numeric(
                 reverse = TRUE,
                 palette = c('white',.color1, .color2), 
                 domain = c(min(.accuracy$mae)-.round_num,
                            max(.accuracy$mae)+.round_num)
               )) %>% 
    data_color(columns = vars(mape),
               colors = scales::col_numeric(
                 reverse = TRUE,
                 palette = c('white',.color1, .color2), 
                 domain = c(min(.accuracy$mape)-.round_num,
                            max(.accuracy$mape)+.round_num)
               )) %>% 
    data_color(columns = vars(mase),
               colors = scales::col_numeric(
                 reverse = TRUE,
                 palette = c('white',.color1, .color2 ), 
                 domain = c(min(.accuracy$mase)-.round_num,
                            max(.accuracy$mase)+.round_num)
               )) %>% 
    data_color(columns = vars(smape),
               colors = scales::col_numeric(
                 reverse = TRUE,
                 palette = c('white',.color1, .color2), 
                 domain = c(min(.accuracy$smape)-.round_num,
                            max(.accuracy$smape)+.round_num)
               )) %>% 
    data_color(columns = vars(rmse),
               colors = scales::col_numeric(
                 reverse = TRUE,
                 palette = c('white',.color1, .color2), 
                 domain = c(min(.accuracy$rmse)-.round_num,
                            max(.accuracy$rmse)+.round_num)
               )) %>% 
    data_color(columns = vars(rsq),
               colors = scales::col_numeric(
                 reverse = FALSE,
                 palette = c('white',.color1, .color2), 
                 domain = c(min(.accuracy$rsq)-.round_num,
                            max(.accuracy$rsq)+.round_num)
               )) 
  
}

accuracy_table(calibration_table_transporte %>% 
                 modeltime_accuracy(), 
               .subtitle = 'Estación Avellaneda')

## PREDICCIONES

forecast_transporte <- calibration_table_transporte %>%
  filter(.model_id %in% c(4,5)) %>%
  modeltime_forecast(
    new_data    = testing(splits_transporte),
    actual_data = df_avellaneda_model
  )

## VISUALIZACIÓN DE LAS PREDICCIONES

forecast_transporte %>% 
  plot_modeltime_forecast(
    .legend_max_width = 30, 
    .interactive      = FALSE,
    .conf_interval_alpha = 0.2, 
    .line_size=0.2
  )

## Predicciones con los mejores modelos: NNAR y MARS (Earth)

calibration_table_transporte %>%
  filter(.model_id %in% c(4,5)) %>%
  modeltime_forecast(
    new_data    = df_avellaneda_model %>%
      filter(date >= min(testing(splits_transporte)$date)) %>%
      mutate(value = NA),
    actual_data = df_avellaneda_model %>%
      filter(date >= min(testing(splits_transporte)$date)) 
  ) %>% 
  plot_modeltime_forecast(
    .legend_max_width = 30, 
    .interactive      = FALSE,
    .conf_interval_alpha = 0.2, 
    .line_size=0.5
  )

## RECALIBRACIÓN DEL MODELO
## Con el modelo NNAR

refit_tbl_transporte <- calibration_table_transporte %>%
  filter(.model_id %in% c(5)) %>% 
  modeltime_refit(data = df_avellaneda_model)

forecast_transporte <- refit_tbl_transporte %>% 
  modeltime_forecast(
    actual_data = df_avellaneda,
    h='1 years'
  )

## Visualización del mejor modelo

forecast_transporte %>% 
  plot_modeltime_forecast(
    .legend_max_width    = 30, 
    .interactive         = FALSE,
    .conf_interval_alpha = 0.2, 
    .line_size           = 0.2, 
  )