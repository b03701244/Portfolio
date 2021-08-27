library(tidyverse)
library(readr)
library(ggplot2)
library(forecast)
library(tidyr)

pmi <- read_csv("pmi.csv")

#find ap
pmi.ap <- pmi[,c(1,2,5,7,9)]
pmi.ap$Release_Date <- mdy(pmi.ap$Release_Date)
ap.ts <- ts(pmi.ap[,(c(2:5))], frequency=12, start=c(2016,3.5))
autoplot(ap.ts)

#sum
pmi.ap.total <- pmi.ap %>%
  mutate(PMI = (ASEAN+India+Korea+Taiwan)/4) %>% .[,c(1,6)]
ap.ts.total <- ts(pmi.ap.total[,2], frequency=12, start=c(2016,3.5))
plot.pmi <- autoplot(ap.ts.total)

fit <- auto.arima(ts(ap.ts.total, frequency=12, start=c(2016,3.5)))
fc <- forecast(fit, h=10)
autoplot(fc)
summary(fit)

