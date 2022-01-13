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
  library(keras)
  library(tensorflow)
  library(ggplot2)
  library(forecast)
  library(quantmod)
  library(gridExtra)
  library(Quandl)
})

## help(package = keras) # Ver help

## CARGAR FUNCIONES PARA NORMALIZACIÓN DE VARIABLES
source(paste0(path,"Funciones.R"))

# source(paste0(path,"Passwords.R"))

## DESCARGAR DATOS SOBRE YPF
getSymbols("^GSPC", 
           auto.assign = TRUE, 
           src = "yahoo")

head(GSPC, n = 3)

## TOMAR COMO SERIE EL PRECIO AJUSTADO DEL ÍNDICE
## serie = arima.sim(n = 2000,
   ##               model = list(ar = c(0.80),ma = c(-0.80)),
     ##             sd = 1)

serie = Ad(GSPC)

## TRANSFORMAMOS LA SERIE PARA CONVERTIRLA EN ESTACIONARIA

diffed = diff(serie, differences = 1)
# diffed = diffed[-1]

supervised = lag_transform(serie, 1)
head(supervised)

## GRAFICO DE LA SERIE, FAC Y FACP

ggtsdisplay(serie)

ggtsdisplay(diffed)

## DIVIDIR EN CONJUNTO DE ENTRENAMIENTO Y TEST

N = nrow(supervised)
n = round(N * 0.80, digits = 0)

train = supervised[1:n, ]      ## ENTRENAR CON LOS PRIMEROS n DATOS
test  = supervised[(n+1):N, ]  ## TESTEAR CON EL RESTO DE LOS DATOS

nrow(train)  ## PARA ENTRENAR
nrow(test)   ## PARA VALIDAR

## ESCALAR LOS DATOS EN UN RANGO DE -1 A 1
Scaled = scale_data(train = train, 
                    test = test, 
                    feature_range = c(-1, 1))

y_train = Scaled$scaled_train[, 2]
x_train = Scaled$scaled_train[, 1]

y_test = Scaled$scaled_test[, 2]
x_test = Scaled$scaled_test[, 1]

## CAMBIAR LA FORMA DE LA ENTRADA A 3-DIM
dim(x_train) <- c(length(x_train), 1, 1)

## ESPECIFICAR LOS ARGUMENTOS REQUERIDOS

X_shape2 = dim(x_train)[2]
X_shape3 = dim(x_train)[3]
batch_size = 1        # must be a common factor of both the train and test samples
units = 100           # can adjust this, in model tuninig phase

## CREAR EL MODELO
model <- keras_model_sequential() 

## PRIMERA OPCIÓN
model %>%
  layer_lstm(units, 
             batch_input_shape = c(batch_size, X_shape2, X_shape3), 
             stateful= TRUE) %>%
  layer_dense(units = 1)

# Keras admite una serie de funciones de activación, 
# unidad lineal rectificada (relu), softmax, sigmoide, tanh, unidad lineal exponencial (elu), entre otras.

## MIRAR LA ESTRUCTURA DEL MODELO
summary(model)

## COMPILAR EL MODELO
model %>% 
  compile(
  loss = 'mean_squared_error',
  optimizer = optimizer_adam(lr = 0.0001 , decay = 1e-6),  
  metrics = c('accuracy')
)

## "binary_crossentropy"  ## PARA CLASIFICACIÓN BINARIO
## "categorical_crossentropy"  ## PARA CLASIFICACIÓN MULTICLASE

# Keras admite varios optimizadores: 
# optimizador de descenso de gradiente estocástico (sgd) 
# estimaciÃ³n de monumento adaptativo (adam)
# tasa de aprendizaje adaptativo (Adadelta), entre otros. 

# Mientras llama al optimizador, el usuario puede especificar la tasa de aprendizaje (lr)
# la tasa de aprendizaje decae en cada actualizaciÃ³n (decadencia) 
# entre otros argumentos específicos de cada optimizador.

## FIT EL MODELO
track = model %>% fit(x_train, 
                      y_train, 
                      epochs = 150, 
                      batch_size = 1,
                      callbacks = callback_early_stopping(patience = 2, monitor = 'acc'),
                      validation_split = 0.3
)

# epochs: el número de veces que el algoritmo 've' todos los datos de entrenamiento.
# batch_size: el tamaño de la muestra que se pasarÃ¡ a travÃ©s del algoritmo en cada Ã©poca. 

## https://keras.rstudio.com/reference/fit.html

plot(track)

## PREDICCIONES 
pred <- model %>%
  predict(x_test, batch_size = 1)
y_pred = round(pred)

## MATRIZ DE CONFUSIÓN
CM = table(y_pred, y_test)

## EVALUAR EL MODELO
evals <- model %>% 
  evaluate(x_test, y_test, batch_size = 3)

accuracy = evals[2][[1]]* 100

print(accuracy)