library(tidyverse)
library(readr)
library(rvest)
library(ggplot2)

DAR <- read_csv("DAR_Historic.csv")
DAR$Revenue <- gsub("[],\\)]", "",DAR$Revenue)
DAR$Revenue <- gsub("^\\(", "-",DAR$Revenue)
DAR$Revenue <- gsub("\\$", "",DAR$Revenue) %>% as.numeric()
DAR <-  DAR %>%
  group_by(Fiscal_Mth) %>%
  summarise(Revenue = sum(Revenue))

url <- "https://web02.mof.gov.tw/njswww/webMain.aspx?sys=220&ym=9001&ymt=11007&kind=21&type=1&funid=i9161&cycle=1&outmode=0&compmode=00&outkind=1&fld0=1&cod018=1&rdm=R159145"
data <- read_html(url) %>%
  html_nodes("table") %>% .[[2]]

table <- data %>% html_table()
table <- table[-1,]
colnames(table) <- c("Date", "Exports")
table <- table %>%
  separate(Date, c("CY", "CM"), "年 ") %>%
  mutate(CY = as.numeric(CY) + 1911)
table$CM <- gsub("月", "", table$CM) %>% as.numeric()
table$Exports <- gsub(",", "", table$Exports) %>% as.numeric()

#get fiscal month and quarter
table <- table %>%
  mutate(Calendar_Mth = CY*100+CM,
         Fiscal_Mth = ifelse(CM < 11, CY*100+CM+2,
         (CY+1)*100+CM-10),
         Exports = Exports*1000)
table <- table %>%
  mutate(FQ = Fiscal_Mth%/%100*10+(Fiscal_Mth%%100-1)%/%3+1)

summ <- DAR %>%
  left_join(table) %>%
  group_by(Fiscal_Mth, FQ) %>%
  summarise(Exports = sum(Exports), Revenue = sum(Revenue)) %>%
  gather("Type", "Value", Exports:Revenue) %>%
  na.omit()%>%
  ungroup()

#make month discreet
summ$Fiscal_Mth <- summ$Fiscal_Mth %>%
  ordered(levels = unique(summ$Fiscal_Mth))

plot.mth <- summ %>%
  ggplot(aes(x=factor(Fiscal_Mth), y=Value, group = Type, color = Type)) + 
  geom_line(size = 1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("Fiscal_Mth")

print(plot.mth)

qtr_data <- summ %>%
  dplyr::group_by(FQ, Type)%>%
  dplyr::summarise(Value = sum(Value)) %>%
  na.omit(.)
#make FQ discrete
qtr_data$FQ <- qtr_data$FQ %>%
  ordered(levels = unique(qtr_data$FQ))

plot.qtr <- qtr_data %>%
  ggplot(aes(x=FQ, y=Value, group = Type, color = Type)) + 
  geom_line(size = 1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("Fiscal_Qtr")

plot.qtr
