plot.gtrends.silent <- function(x, ...) {
  df <- x$interest_over_time
  df$date <- as.Date(df$date)
  df$hits <- if(typeof(df$hits) == 'character'){
    as.numeric(gsub('<','',df$hits))
  } else {
    df$hits
  }
  
  df$legend <- paste(df$keyword, " (", df$geo, ")", sep = "")
  
  p <- ggplot(df, aes_string(x = "date", y = "hits", color = "legend")) +
    geom_line() +
    xlab("Date") +
    ylab("Search hits") +
    ggtitle("Interest over time") +
    theme_bw() +
    theme(legend.title = element_blank())
  
  return(p)
}
