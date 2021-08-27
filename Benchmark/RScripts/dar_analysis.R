library(readr)
library(tidyverse)
library(forecast)

#exclude most recent values
dar <- read_csv("C:\\Users\\hlai\\Analog Devices, Inc\\APR-Data-Team - Power BI Development\\Project\\revenue\\dar_revenue.csv") %>%
  .[-1,]
dar$Revenue <- gsub("[],\\)]", "",dar$Revenue)
dar$Revenue <- gsub("^\\(", "-",dar$Revenue)
dar$Revenue <- gsub("\\$", "",dar$Revenue) %>% as.numeric()

#by week data
darwk <- dar %>%
  group_by(Fiscal_Wk) %>%
  summarise(Revenue = sum(Revenue)) %>%
  filter(Fiscal_Wk != max(Fiscal_Wk)) %>%
  arrange(Fiscal_Wk)

dar.ts <- ts(darwk[,2], start = c(min(darwk$Fiscal_Wk)%/%100+min(darwk$Fiscal_Wk)%%100/52), frequency=52)
autoplot(dar.ts)

#fitting auto arima
fit <- auto.arima(dar.ts)
fc <- forecast(fit, h=10)
plot.fc <- autoplot(fc)
#get accuracy and forecast
summary(fc)
plot(decompose(dar.ts[,1]))

#join calendar to get fiscal qtr
cal <- read_csv("C:\\Users\\hlai\\Analog Devices, Inc\\APR-Data-Team - Power BI Development\\Project\\master_data\\Calendar_Week.csv") %>%
  .[-1,]

darmth <- dar %>%
  left_join(cal[,c(1:2)]) %>%
  mutate(FM = ceiling(Fiscal_Wk%%100 * 1/52 * 12)+Fiscal_Wk%/%100*100) %>%
  group_by(FM) %>%
  summarise(Revenue = sum(Revenue)) %>%
  filter(FM != max(FM)) %>%
  arrange(FM)

darmth.ts <- ts(darmth[,2], start = c(min(darmth$FM)%/%100+min(darmth$FM)%%100/12), frequency=12)
ggseasonplot(darmth.ts) + ggtitle("Revenue Montly Trend: Linear Time View")
ggseasonplot(darmth.ts, polar = T) + ggtitle("Revenue Montly Trend: Polar View")

