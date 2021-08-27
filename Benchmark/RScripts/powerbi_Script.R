library(tidyverse)

DAR <- read_csv("DAR_Historic.csv")
DAR$Revenue <- gsub("[],\\)]", "",DAR$Revenue)
DAR$Revenue <- gsub("^\\(", "-",DAR$Revenue)
DAR$Revenue <- gsub("\\$", "",DAR$Revenue) %>% as.numeric()
DAR <-  DAR %>%
  group_by(Fiscal_Mth) %>%
  summarise(Revenue = sum(Revenue), `POS Resale Value`= sum(`POS Resale Value`))%>%
  arrange(desc(Fiscal_Mth), by_group=TRUE) %>%
  mutate(RevGrowth = (Revenue - lead(Revenue))/lead(Revenue)*100,
         POSGrowth = (`POS Resale Value` - lead(`POS Resale Value`))/lead(Revenue)*100)
