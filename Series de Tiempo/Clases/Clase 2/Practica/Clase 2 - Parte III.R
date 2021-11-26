# Limpiar R para comenzar el analisis #
rm(list=ls(all=TRUE))

library(ggfortify)
library(tseries)
library(forecast)

data(AirPassengers)
AP <- AirPassengers
# analizamos la clase 
class(AP)

# Leo los datos

AP

# Veo si hay missing 
sum(is.na(AP))

# Veo la frecuencia de la serie de tiempo
frequency(AP)

# Veo los ciclos de la serie
cycle(AP)

# Breve resumen de los datos
summary(AP)

# Graficos de los datos
plot(AP,xlab="Dias", ylab = "Numeros de pasajeros en miles",main="Numeros de pasajeros entre 1949 y 1961")

autoplot(AP) + labs(x ="Dias", y = "Numeros de pasajeros en miles", title="Numeros de pasajeros entre 1949 y 1961") 

boxplot(AP~cycle(AP),xlab="Dias", ylab = "Numeros de pasajeros en miles" ,main ="Boxplot mensual de Numeros de pasajeros entre 1949 y 1961")

# estimacion de tendencia
library(plotly)
library(dplyr)
library(TSstudio)
library(lubridate)

ap_smooth <- ts_ma(AirPassengers, n = 6,
                   separate = FALSE)

ap_smooth$plot %>%
  layout(legend = list(x = 0.1, y = 0.9))

# quitar tendencia a la serie
df <- ts_to_prophet(AirPassengers) %>% 
  select(date = ds, y) %>% 
  left_join(ts_to_prophet(ap_smooth$ma_6) %>%
              select(date = ds, trend = y), by = "date")


head(df, 8)

# quitamos la tendencia 
df$detrend <- df$y - df$trend

head(df, 8)

# resumen grafico de lo visto 

ts_plot(df,
        title = "AirPassenger quitamos tendencia") %>%
  layout(legend = list(x = 0.1, y = 0.9))

######################
# COMPONENTE ESTACIONAL
######################
# nuevas variables --

df$year <- year(df$date)
df$month <- month(df$date)


p <- plot_ly()
for(i in unique(df$year)){
  temp <- NULL
  temp <- df %>% filter(year == i) 
  p <- p %>% add_lines(x = temp$month,
                       y = temp$detrend,
                       name = i)
  
}
# imprimo grafico
p


# grafico con tendencia estacional
seasonal_comp <- df %>% 
  group_by(month) %>%
  summarise(month_avg = mean(detrend, na.rm = TRUE),
            .groups = "drop")


p %>% add_lines(x = seasonal_comp$month, 
                y = seasonal_comp$month_avg,
                line = list(color = "black", dash = "dash", width = 4),
                name = "Seasonal Component")


# Componente Irregular

df <- df %>% left_join(seasonal_comp, by = "month")


df$irregular <- df$y - df$trend - df$month_avg
head(df)


ts_plot(df[, c("date", "y" ,"trend", "detrend", "month_avg", "irregular")], 
        title = "AirPassenger and its Components",
        type = "multiple")



# REsumen de la serie con descomposicion aditiva y multiplicativa mediante otra funcion 
ts_decompose(AirPassengers, type = "both")

