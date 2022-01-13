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

## CARGAR DATASET ##

df_emae <- sknifedatar::emae_series

df_emae %>% 
  mutate(value=round(value,2)) %>% 
  head(5) %>% 
  gt() %>% 
  tab_header('Estimador Mensual de Actividad Económica (EMAE)')

FECHA = '2020-02-01' # máxima fecha para partición en train test (último mes pre pandemia)

x11()
df_emae %>% filter(sector == 'Transporte y comunicaciones', date <= FECHA) %>% 
  group_by(sector) %>% 
  plot_stl_diagnostics(
    .date_var=date, 
    .value=value, 
    .frequency = 'auto', 
    .trend = 'auto', 
    .feature_set = c("observed", "season", "trend", "remainder"),
    .interactive = FALSE
  )

x11()
df_emae %>% 
  filter(sector=='Transporte y comunicaciones', date <= FECHA) %>%  
  group_by(sector) %>% 
  plot_seasonal_diagnostics(date, value, .interactive = FALSE)


df_emae %>% filter(sector=='Transporte y comunicaciones', date <= FECHA) %>%  
  group_by(sector) %>% 
  plot_acf_diagnostics(date, value, 
                       .show_white_noise_bars = TRUE,
                       .white_noise_line_color = 'red',
                       .white_noise_line_type = 2,
                       .line_size=0.5,
                       .point_size=1.5,
                       .interactive = FALSE)

## Detección de anomalías
x11()
df_emae %>%
  group_by(sector) %>%
  plot_anomaly_diagnostics(
    date,
    value,
    .facet_ncol = 4,
    .max_anomalies = 0.05,
    .facet_scales = 'free_y',
    .message = TRUE,
    .line_size = 0.7,
    .anom_size = 1,
    .interactive = FALSE
  )

## Dataframe anidado que incluye una fila por sector
nested_df_emae  <- df_emae %>% 
  filter(date<=FECHA) %>% 
  nest(nested_column=-sector)

## Se definen recetas de transformación de variables
receta_emae_1 = recipe(value ~ ., data = df_emae %>% 
                         select(-sector)) %>%
  step_date(date, features = c("month", "quarter", "year"), 
            ordinal = TRUE)

receta_emae_2 = receta_emae_1 %>% 
  step_mutate(date_num = as.numeric(date)) %>%
  step_normalize(date_num) %>%
  step_rm(date) %>% 
  step_dummy(date_month)

# Modelo ARIMA boosted
m_arima_boosted_emae <- workflow() %>% 
  add_recipe(receta_emae_1) %>% 
  add_model(arima_boost() %>% 
              set_engine(engine = "auto_arima_xgboost"))

# Modelo seasonal
m_seasonal_emae <- seasonal_reg() %>%
  set_engine("stlm_arima")

# Modelo prophet boosted
m_prophet_boost_emae <- workflow() %>% 
  add_recipe(receta_emae_1) %>% 
  add_model(prophet_boost(mode='regression') %>%
              set_engine("prophet_xgboost")) 

# Modelo NNetar
m_nnetar_emae <- workflow() %>%
  add_recipe(receta_emae_1) %>%
  add_model(nnetar_reg() %>% 
              set_engine("nnetar"))

# Modelo MARS
m_mars_emae <- workflow() %>%
  add_recipe(receta_emae_2) %>%
  add_model(mars(mode = "regression") %>% 
              set_engine("earth"))

# Modelo Elastic net
m_glmnet_emae <- workflow() %>%
  add_recipe(receta_emae_2) %>%
  add_model(linear_reg(penalty = 0.01, mixture = 0.1) %>% 
              set_engine("glmnet"))

# Modelo Xgboost
m_xgboost_emae <- workflow() %>%
  add_recipe(receta_emae_2) %>%
  add_model(boost_tree() %>% 
              set_engine("xgboost"))

## Se considera una partición de 85% para train 
## y 15% para evaluación
SPLIT_PROP_EMAE <- 0.85

## se utiliza la función modeltime_multifit() 
## para entrenarlos sobre cada serie
model_table_emae <- modeltime_multifit(
  serie = nested_df_emae,
  .prop = SPLIT_PROP_EMAE,
  m_arima_boosted_emae,
  m_seasonal_emae,
  m_prophet_boost_emae,
  m_nnetar_emae,
  m_mars_emae,
  m_glmnet_emae,
  m_xgboost_emae
) 

## El output de la función es una lista con dos elementos
model_table_emae$table_time

## Las dos primeras columnas identifican el nombre y los datos 
## de las series, posteriormente se genera automáticamente 
## una columna para cada modelo especificado, 
## donde los modelos ya están entrenados sobre 
## la partición de train de las series

## consultar el modelo "m_seasonal_emae" ajustado sobre la serie de Comercio
model_table_emae$table_time$m_seasonal_emae[[1]]
model_table_emae$table_time$nested_model[[1]]

headers_transporte <- model_table_emae$table_time$sector

g_metrics_emae <- list()
for(i in 1:length(headers_transporte)){
  temp <- model_table_emae$models_accuracy %>% 
    mutate(rsq = ifelse(is.na(rsq),0,rsq)) %>% 
    filter(name_serie == headers_transporte[i]) %>% 
    select(-name_serie)
  
  g_metrics_emae[[i]] <- accuracy_table(
    .accuracy = temp, 
    .subtitle = headers_transporte[i])
}

forecast_emae <- modeltime_multiforecast(
  model_table_emae$table_time,
  .prop = SPLIT_PROP_EMAE
)

x11()
forecast_emae %>% 
  select(sector, nested_forecast) %>% 
  unnest(nested_forecast) %>% 
  group_by(sector) %>% 
  plot_modeltime_forecast(
    .legend_max_width = 12,
    .facet_ncol = 4, 
    .line_size = 0.5,
    .interactive = FALSE,
    .facet_scales = 'free_y',
    .title='Proyecciones') 

## Selección del mejor modelo

best_model_emae <- modeltime_multibestmodel(
  .table = forecast_emae,
  .metric = "rmse",
  .minimize = TRUE
)

## Mediante la función modeltime_multirefit(), de sknifedatar 
## se entrena el mejor modelo para cada serie, utilizando todos los datos disponibles pre-pandemia

model_refit_emae <- modeltime_multirefit(best_model_emae)

## Se unen los datos de la tabla original

model_refit_emae <- model_refit_emae %>% 
  bind_cols(df_emae %>% 
              nest(nested_column=-sector) %>% 
              select(-sector) %>% 
              rename(actual_data=nested_column)
  )

## se utiliza una función modificada, 
## debido a que se busca predecir a partir 
## de determinada fecha y comparar la predicción 
## contra el valor observado durante la pandemia

modeltime_multiforecast_pandemia <- function(models_table,
                                             .fecha = '2020-02-01', 
                                             .prop = 0.7) {
  
  models_table %>% mutate(
    nested_forecast = pmap(list(calibration, nested_column, actual_data), 
                           function(calibration, nested_column, actual_data) {
                             calibration %>% modeltime_forecast(
                               new_data = actual_data  %>% filter(date >= .fecha), 
                               actual_data = actual_data
                             ) %>%
                               mutate(
                                 .model_details = .model_desc,
                                 ..model_desc = gsub("[[:punct:][:digit:][:cntrl:]]", "", .model_desc))
                           }))
  
}

## Aplicando esta función se obtienen 
## las proyecciones durante la pandemia 

forecast_best_emae <- modeltime_multiforecast_pandemia(model_refit_emae,
                                                       .fecha = FECHA,
                                                       .prop = SPLIT_PROP_EMAE)

## Se visualiza la predicción durante 
## el período de pandemia contra los valores reales

x11()
forecast_best_emae %>% 
  select(sector, nested_forecast) %>% 
  unnest(nested_forecast) %>% 
  group_by(sector) %>% 
  plot_modeltime_forecast(
    .legend_max_width = 12,
    .facet_ncol = 4, 
    .line_size = 0.5,
    .interactive = FALSE,
    .facet_scales = 'free_y',
    .title='Proyecciones'
  ) 