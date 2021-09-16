library(tidyverse)
library(readr)
library(janitor)
library(ggplot2)
library(ggfortify)
library(TTR)
library(forecast)
library(fable)
library(vars)
library(tseries)
library(MTS)

ana <- read_csv("Analog_Semi_WSTS.csv")
ana <- clean_names(ana[-c(1,2,4),-c(2,5,10,12,14)]) %>%
  row_to_names(1)
#calendar month
colnames(ana)[c(1,8,9)] <- c("CM", "GENERAL PURPOSE ANALOG","APPLICATION SPECIFIC ANALOG")
ana <- sapply(ana, as.numeric) %>%
  as.data.frame()

#get revenue
#exclude most recent values
dar <- read_csv("DAR_6yrs.csv") %>%
  .[-1,]
dar$Revenue <- gsub("[],\\)]", "",dar$Revenue)
dar$Revenue <- gsub("^\\(", "-",dar$Revenue)
dar$Revenue <- gsub("\\$", "",dar$Revenue) %>% as.numeric()

#get cal to join fiscal month
#join calendar to get fiscal qtr
cal <- read_csv("C:\\Users\\hlai\\Analog Devices, Inc\\APR-Data-Team - Power BI Development\\Project\\master_data\\Calendar_Week.csv") %>%
  .[-1,-6]

dar <- dar %>%
  left_join(cal[,c(1:2)]) %>%
  mutate(FM = ceiling(Fiscal_Wk%%100 * 1/52 * 12)+Fiscal_Wk%/%100*100) %>%
  dplyr::group_by(FM) %>%
  summarise(Revenue = sum(Revenue)) %>%
  filter(FM != max(FM)) %>%
  arrange(FM)

dar <- dar %>%
  mutate(Revenue = Revenue/100,
         CM = ifelse(
           FM%%100 < 3, (FM%/%100 - 1) * 100 + (FM%%100+10),
           (FM%/%100) * 100 + (FM%%100-2)
         ))
dar <- dar[dar$FM!=201813,]

df <- ana %>%
  left_join(dar)%>%na.omit %>% as.data.frame()

lineplot <- df %>% .[,-10] %>%
  gather(Type, Value, AM:Revenue) %>%
  ggplot() +
  geom_line(aes(x=factor(CM), y=Value, color=Type, group=Type)) +
  xlab("Calendar Month")+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


#read unemployment
em <- read_csv("Unemploy.csv")[-nrow(em),c(9,17)]
colnames(em)[2] <- "UnEmploy"

#adding unemployment rate to the model
df <- cbind(df, em[,2])

#time series analysis
ana.ts <- ts(df[,c(6,7,11,12)] %>% na.omit(), start = c(2014,11),frequency = 12)
plot(ana.ts, ann=FALSE); title(main = "Semiconductor Revenue, ADI Revenue, and Unemployment Rate Time Series")

fitww <- auto.arima(ana.ts[,2])
fcww <- forecast(fitww, h=12)
wwfcst <- autoplot(fcww)
fcsttable <- fcww

VARselect(ana.ts, lag.max=8,
          type="const")[["selection"]]

var1 <- vars::VAR(ana.ts, p=3, type="trend")
serial.test(var1, lags.pt=10, type="PT.asymptotic")

var2 <- vars::VAR(ana.ts, p=4, type="trend")

modelsumm <- summary(var2)

fcst.plot <- autoplot(forecast(var2)) +
  ggtitle("Time Series Plot of the stationary Time-Series")
pred <- predict(var2, n.ahead = 10)

#test for serial correlation
serial <- serial.test(var2, lags.pt=10, type="PT.asymptotic")

#see if unemployment Granger causes the other
cause.em <- causality(var2, cause = "UnEmploy")$Granger

#check for heterostochasity
arch <- arch.test(var2, lags.multi = 10, multivariate.only = TRUE)

#normal
norm <- normality.test(var2, multivariate.only = TRUE)
#did not pass normality test for residuals

#stability
stab <- stability(var2, type="OLS-CUSUM") %>% plot
