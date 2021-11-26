
## FUNCI?N PARA CONSTRUIR UNA MATRIZ CON LOS VALORES DE AIC
AIC_Matrix <- function(ts,p.order = 1, q.order = 1){
  require(forecast)
  aic_matrix = matrix(data = NA, nrow = p.order, ncol = q.order)
  for(i in 0:p.order){
    for(j in 0:q.order){
      aic = arima(ts,order = c(i,0,j))$aic
      aic_matrix[i,j] = aic
    }
  }
  rownames(aic_matrix) = c(1:p.order)
  colnames(aic_matrix) = c(1:q.order)
  return(aic_matrix)
}

## CREAMOS UNA FUNCI?N PARA TESTEAR NORMALIDAD ##
Normality_Test <- function(ts,type = c("JB", "AD", "SW")){
  require(tseries)
  require(nortest)
  if(type == "JB"){
    p_val = jarque.bera.test(ts)$p.value
    stat  = jarque.bera.test(ts)$statistic
  } else if(type == "AD"){
    p_val = ad.test(ts)$p.value
    stat  = ad.test(ts)$statistic
  } else {
    p_val = shapiro.test(ts)$p.value
    stat  = shapiro.test(ts)$statistic
  }
  
  table = data.frame(P_Value = p_val,
                     Statistic = stat)
  return(table)
}

## LO FORMALIZAMOS EN UNA FUNCI?N ##
Incorrelation <- function(ts, type = c("Ljung-Box","Box-Pierce"), fitdf = 0){
  p_ljung_box = NULL
  s_ljung_box = NULL
  for(i in 0:(length(ts)/4)){
    p_ljung_box[i] = Box.test(ts,lag = i,type = type,fitdf = fitdf)$p.value
    s_ljung_box[i] = Box.test(ts,lag = i,type = type,fitdf = fitdf)$statistic
  }
  table = data.frame(j = 1:(length(ts)/4),
                     P_Value = p_ljung_box,
                     Statistic = s_ljung_box)
  return(table)
}


## LE INCORPORAMOS UN IF ##
Incorrelation2 <- function(ts, type = c("Ljung-Box","Box-Pierce"), fitdf = 0){
  if(is.ts(ts)){
    p_ljung_box = NULL
    s_ljung_box = NULL
    for(i in 0:(length(ts)/4)){
      p_ljung_box[i] = Box.test(ts,lag = i,type = type,fitdf = fitdf)$p.value
      s_ljung_box[i] = Box.test(ts,lag = i,type = type,fitdf = fitdf)$statistic
    }
    table = data.frame(id = 1:(length(ts)/4),
                       P_Value = p_ljung_box,
                       Statistic = s_ljung_box)
    return(table)  
  } else {
    print("El objeto no es una serie de tiempo")  
  }
}
