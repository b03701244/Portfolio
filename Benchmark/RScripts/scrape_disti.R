library(rvest)
library(tidyverse)

arrow <- "https://ycharts.com/companies/ARW/revenues_annual"
avnet <- "https://ycharts.com/companies/AVT/revenues_annual"
#get left box
list <- c(arrow, avnet)
list2 <- list()
names(list2) <- c("arrow", "avnet")

readurl <- for (i in 1:length(list)){
  box <- list[i] %>%
    read_html %>%
    html_nodes(xpath ='//*[@ng-show="initPhase"]') %>%
    html_nodes("table") %>% html_table()
  #change column names
  box <- rbind(box[[1]], setNames(box[[2]], names(box[[1]])))
  box[,1] <- box[,1] %>%
    substring(nchar(.)-3, nchar(.))
  colnames(box) <- c("CY", "Rev")
  box[str_which(box$Rev, "B"),2] <- as.numeric(str_remove(box[str_which(box$Rev, "B"),2], "B")) * 1000000000
  box[str_which(box$Rev, "M"),2] <- as.numeric(str_remove(box[str_which(box$Rev, "M"),2], "M")) * 1000000
  list2[[i]] <- box
}

wtm <- "https://za.investing.com/equities/wt-microelectr-income-statement?amp;period_type=quarterly&periods=latest&period_type=annually"
table <- wtm %>%
  read_html %>%
  html_nodes(xpath = '//*[@class = "js-table-wrapper common-table-comp "]')  %>%
  html_nodes("table")  %>% .[[1]] %>%
  html_table() %>% .[,-ncol(.)]
