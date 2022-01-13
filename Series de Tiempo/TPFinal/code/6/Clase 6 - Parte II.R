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

## CARGAR LOS PAQUETES ##

suppressPackageStartupMessages({
  library(dplyr)
  library(gt)
  library(ggplot2)
  library(hrbrthemes)
  library(trendyy)
  library(purrr)
  library(lubridate)
  library(tidyr)
  library(tsibble)
  library(vars)
})

words <- c("bitcoin", "mining", "gpu", 
           "money", "nvidia", "musk", 
           "startup", "blockchain", "python", 
           "petroleum", "credit", "iphone")

desde <- "2018-01-01"
hasta <- Sys.Date()

bitcoin_trend <- purrr::map_dfr(words,
  ~ trendyy::get_interest(trendyy::trendy(., 
                                          from = desde, 
                                          to = hasta))
) %>% 
  select(date, hits, keyword) %>% 
  mutate(date = lubridate::date(date))

## VENTANA DE PRONÓSTICO Y PERIODICIDAD DE LOS DATOS
window <- 52
season_duration <- 52

time_series <- tsibble::as_tsibble(
  bitcoin_trend, 
  index = date, 
  key = keyword, 
  regular = T
) %>% 
  tidyr::spread(keyword, hits)  %>% 
  as.ts(frequency = season_duration)

var_model <- vars::VAR(time_series)

resultados = summary(var_model)

resultados$varresult$bitcoin

resultados$varresult$python

summary(var_model)$varresult$python %>% 
  broom::tidy() %>% 
  mutate_if(is.numeric, round, 3) %>% 
  gt() %>%
  tab_header(
    title = md("**VAR Summary (python)**")
  ) %>% 
  tab_style(
    style = cell_text(
      color = "white",
      size = 10,
      align = "center",
      font = "PT Sans",
      weight = "bold"),
    locations = cells_column_labels(
      columns = vars("term", "estimate", "std.error", "statistic", "p.value")
    )) %>%
  data_color(
    columns = vars(p.value),
    colors = scales::col_numeric(
      palette = c("#1a9850", "#d73027"),
      domain = c(0, 1)))

## FORECASTING Y PLOTEO DEL MODELO VAR
var_model %>% 
  forecast::forecast(window) %>% 
  forecast::autoplot() + 
  scale_y_continuous(limits = c(0, 100)) +
  theme_ipsum(base_family = "sans") +
  theme(panel.grid = element_line(linetype = "dashed")) + 
  facet_wrap( ~ series, scales = "fixed", ncol = 2)

## OTROS PLOTEOS

fcst <- forecast(var_model)
plot(fcst, xlab="Year")

par(mar = c(1,1,1,1))
plot(predict(var_model, 
             n.ahead = window, 
             ci = 0.95), 
     xlab = "Tiempo", 
     ylab = "En %")
