library(tidyverse)
library(lubridate)
library(extrafont)
library(readxl)

DistiID <- read_csv("DistiID.csv")[,-2]
colnames(DistiID)[2] <- "DistributorID"
file <- list.files(file.path("History", Sys.Date()), "*.xlsx")

ecbl.val <- read_excel(file.path("History", Sys.Date(), file))[-1,-c(3, 5:7,9)]
ecbl.val <- ecbl.val %>% 
  merge(DistiID, by.x = "Tracking #", by.y = "Sold To # (Pur)")
ecbl.val <- ecbl.val[,c(1, 11, 3:10)] %>%
  group_by(DistributorID, Material)
ecbl.val$`Deficient Value` <- gsub("[(]", "-", ecbl.val$`Deficient Value`)
ecbl.val$`Deficient Value` <- gsub("[)$,]", "", ecbl.val$`Deficient Value`)
ecbl.val$`Deficient Value` <- ecbl.val$`Deficient Value` %>% as.numeric()
#join end customer backlog's fcst and firm demand
ecbl <- read_csv("ecbl.csv")
ecbl$CRDate <- ymd(ecbl$CRDate)

data_to_join <- ecbl %>% select(DistributorID, PartNumber, BLOGQTY, CRDate,`BL-Type`) %>%
  filter(CRDate < Sys.Date()+86) %>% #get 90-day firm backlogs
  group_by(DistributorID, PartNumber, `BL-Type`) %>%
  dplyr::summarise(QTY = sum(BLOGQTY)) %>%
  ungroup() %>% mutate( DistributorID = case_when(
    DistributorID == "ARROW APR"~ "ARROW-APR",
    DistributorID == "ARROW AU/NZ" ~ "ARROW-AU",
    DistributorID == "ARROW INDIA" ~ "ARROW-IN",
    DistributorID == "CYTECH/AP" ~ "MACNICA-APR",
    DistributorID == "SHEENBANG/KR" ~ "SHEENBANG",
    DistributorID == "EXCELPOINT AUSTR" ~ "ESPL-AU",
    DistributorID == "EXCELPOINT INDIA" ~ "ESPL-IN",
    DistributorID == "EXCELPOINT" ~ "ESPL-SG",
    TRUE ~ DistributorID
  ))

ecbl.val <- merge(data_to_join, ecbl.val, by.x = c("DistributorID", "PartNumber"), by.y = c("DistributorID", "Material"))
ecbl.val <- ecbl.val %>% spread("BL-Type", QTY, fill = 0)

#make it into wide data
ecbl.val <- ecbl.val %>% #count the percentage
  mutate(`FIRM%` = paste0(round(FIRM / `ECBL CRD OD - 13Wks Qty` * 100, digits = 0), "%"), 
         `FCST%` = paste0(round(FCST / `ECBL CRD OD - 13Wks Qty` * 100, digits = 0), "%"),
         `BOND%` = paste0(round(BOND / `ECBL CRD OD - 13Wks Qty` * 100, digits = 0), "%"),
         `SFTY%` = paste0(round(SFTY / `ECBL CRD OD - 13Wks Qty` * 100, digits = 0), "%"),
         `HOLD%` = paste0(round(HOLD / `ECBL CRD OD - 13Wks Qty`* 100, digits = 0), "%")) %>%
  .[,c(3, 1:2, 4, 13, 16, 12, 17, 11, 18, 15, 19, 14,20, 5, 6:10)]

ecbl.val <- ecbl.val %>%
  group_by(DistributorID) %>%
  arrange(DistributorID, desc(`Deficient Value`)) %>%
  ungroup()
ecbl.val <- na.omit(ecbl.val, 0)

Arrow_parts_list <- ecbl.val$PartNumber[ecbl.val$DistributorID == "ARROW-APR" & ecbl.val$`Deficient Value`>30000]
arrow_parts <- ecbl[ecbl$PartNumber %in% Arrow_parts_list & ecbl$DistributorID == "ARROW APR" &
                        ecbl$CRDate < Sys.Date() + 74,][,c(2,5,6,14,15,21,34)] #13 weeks

write_csv(ecbl.val %>%
            filter(`Deficient Value`>30000), file.path( Sys.Date(), "ECBL_cleanup.csv"), na = "")
write_csv(arrow_parts, file.path(Sys.Date(), "arrow_parts.csv"))

#draw first scatter plot
library(dplyr)
library(ggplot2)
library(gridExtra)
options(scipen=5) #not to use exponential
disti_list <- unique(ecbl.val$DistributorID[ecbl.val$`Deficient Value`>30000])
myplot <- list()
for(i in 1:length(disti_list)){
  scatter_plot <-
    ecbl.val %>%
    filter(DistributorID == disti_list[i]) %>%
    ggplot + geom_point(aes(x = `ECBL CRD OD - 13Wks Qty`/1000, y = `Total ECBL Support Qty`/1000), size = 2)+
    geom_point(data = ecbl.val[ecbl.val$`Deficient Value` > 30000 & ecbl.val$DistributorID == disti_list[i],], 
               aes(x = (`ECBL CRD OD - 13Wks Qty`/1000), y = (`Total ECBL Support Qty`/1000), col=PartNumber), size = 5) +
    ggtitle(paste0(disti_list[i],"- Support v.s. ECBL Qty")) +
    xlab("ECBL Qty (K)") +
    ylab("Total Support Qty (K)")+ theme_bw()+
    theme(plot.title = element_text(size = 12.5, face = "bold"))+
    geom_abline() +
    scale_y_sqrt() +
    scale_x_sqrt() +
    scale_colour_discrete("Parts with Deficient $ > $30K")
  myplot[[i]] <- scatter_plot
}

#draw bar plot
myplot2 <- list()
for(k in 1:length(disti_list)){
  #get data
  total_data <- ecbl.val %>%
    filter(DistributorID == disti_list[k], `Deficient Value` > 30000) %>%
    select(`Total ECBL Support Qty`, PartNumber)
  by_type_data <- ecbl.val %>%
    filter(DistributorID == disti_list[k], `Deficient Value` > 30000) %>%
    select(FIRM, FCST, BOND, SFTY, PartNumber) %>%
    gather(Type, `Qty_by_type`, FIRM:SFTY)
  #for total labels
  no.type <- by_type_data %>% select(PartNumber, Qty_by_type) %>% 
    group_by(PartNumber) %>% summarise(Qty = sum(Qty_by_type))
  #plot bar chart
  bar_chart <- ggplot() +
    geom_col(data = by_type_data, aes(y=Qty_by_type/1000, x=reorder(PartNumber, -Qty_by_type), fill=Type), 
             position="stack", width = 0.5) +
    geom_col(data = total_data, aes(y=`Total ECBL Support Qty`/1000, x=PartNumber, 
                                    fill="Total Support Qty\n= ADI Backlog\n + Inventory\n + In Transit"),
             position = position_nudge(x = 0.3), width = 0.5, colour = "blue")+
    geom_text(data = no.type, aes(y=Qty/1000, x=reorder(PartNumber, -Qty), label = round(Qty/1000,0)),
              position=position_dodge(width=0.9), vjust=-0.5, size=3) +
    geom_text(data = total_data, aes(y=`Total ECBL Support Qty`/1000, x=PartNumber, label = round(`Total ECBL Support Qty`/1000,0)), 
              position = position_nudge(x = 0.3), vjust=1.5, size=3) +
    ggtitle(paste0(disti_list[k], "- ECBL v.s. Support Qty with Deficient $ > 30K"))+
    ylab("Qty (K)") +
    xlab("Part Number")+ theme_bw()+
    theme(plot.title = element_text(size = 12.5, face = "bold"), axis.text.x = element_text(angle=90, vjust=0.5, hjust = 1))
  myplot2[[k]] <- bar_chart
}

#lollipop plot
dat.loll <- ecbl.val %>%
  select(DistributorID, `Total ECBL Support Qty`, `ECBL CRD OD - 13Wks Qty`, PartNumber, `Deficient Value`) %>%
  group_by(DistributorID, PartNumber) %>%
  summarise(`Total ECBL Support Qty` = sum(`Total ECBL Support Qty`),
            `ECBL CRD OD - 13Wks Qty` = sum(`ECBL CRD OD - 13Wks Qty`),
            `Deficient Value` = sum(`Deficient Value`)) %>%
  mutate(`Support %` = `Total ECBL Support Qty`/`ECBL CRD OD - 13Wks Qty`*100)

plot.l <- list()
for(k in 1:length(disti_list)){
  lollipop.chart <- dat.loll %>%
    filter(DistributorID==disti_list[[k]], `Support %` < 100 ,abs(`Deficient Value`)>30000) %>%
    ggplot(aes(x=reorder(PartNumber, `Support %`), y=`Support %`, label = round(`Support %`,0))) +
    geom_segment(aes(x = reorder(PartNumber, `Support %`), xend = PartNumber, y = 0, yend = `Support %`))+
    geom_point(color="orange", size=7) +
    theme(plot.title = element_text(size = 12, face = "bold"), axis.text.x = element_text(angle=90, vjust=0.5, hjust = 1))+
    scale_y_continuous(limits = c(0,100))+
    geom_text(size = 4.5)+
    ggtitle(paste0("Support % of Parts with Deficient $ > 30K: ", disti_list[[k]]))+
    ylab("Support % (Total Disti Support Qty/ 13-Wk ECBL Qty)")+
    xlab("Part Number")+
    theme_bw()+
    coord_flip()
  plot.l[[k]] <- lollipop.chart
}

#run files
library(rmarkdown)
for(v in 1:length(disti_list)){
  render("ecbl.rmd",
         output_file=paste0(disti_list[[v]], "_", Sys.Date(), ".html"),
         params=list(new_title=paste0("Total Support v.s. ECBL Comparison Analysis: ", disti_list[[v]])))
}