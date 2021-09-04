library(tidyverse)
library(readr)
library(rvest)
library(ggplot2)
library(zoo)

DAR <- read_csv("DAR_Historic.csv")
DAR$Revenue <- gsub("[],\\)]", "",DAR$Revenue)
DAR$Revenue <- gsub("^\\(", "-",DAR$Revenue)
DAR$Revenue <- gsub("\\$", "",DAR$Revenue) %>% as.numeric()

DAR <-  DAR %>%
    group_by(Fiscal_Mth, End_Mkt_Segment) %>%
    filter(End_Mkt_Segment %in% c("AEG", "ASD", "AUT", "COM", "CON", "DHC", "INS")) %>%
    summarise(Revenue = sum(Revenue)) %>%
    spread(End_Mkt_Segment,Revenue, fill = 0)

#get mt data
url <- "https://web02.mof.gov.tw/njswww/webMain.aspx?sys=220&ym=9001&ymt=11007&kind=21&type=1&funid=i9161&cycle=1&outmode=0&compmode=00&outkind=1&fld0=1&cod018=1&rdm=R159145"
data <- read_html(url) %>%
    html_nodes("table") %>% .[[2]]
table <- data %>% html_table()
table <- table[-1,]
colnames(table) <- c("Date", "MachineExports")
Sys.setlocale("LC_ALL","Chinese")
table <- table %>%
    separate(Date, c("CY", "CM"), "年 ") %>%
    mutate(CY = as.numeric(CY) + 1911)
table$CM <- gsub("月", "", table$CM) %>% as.numeric()
table$MachineExports <- gsub(",", "", table$MachineExports) %>% as.numeric()

#get fiscal month and quarter
table <- table %>%
    mutate(Calendar_Mth = CY*100+CM,
           Fiscal_Mth = ifelse(CM < 11, CY*100+CM+2,
                               (CY+1)*100+CM-10),
           MachineExports = MachineExports*1000)
table <- table %>%
    mutate(FQ = Fiscal_Mth%/%100*10+(Fiscal_Mth%%100-1)%/%3+1)
by_seg <- DAR %>%
    left_join(table) %>%
    group_by(FQ) %>%
    summarise_at(c(1:8,11), sum)

delta <- function(x){
    x <-( x - lag(x))/lag(x)*100
    x <- rollmean(x, 4, fill = NA)
}
seg_delta <- by_seg
seg_delta[,c(3:10)] <- lapply(by_seg[,c(3:10)], delta)
seg_delta <- seg_delta %>%
    gather(Type, Delta, AEG:MachineExports) %>% na.omit()

data <- seg_delta %>%
    spread(Type, Delta)
mt <- filter(seg_delta, Type == "MachineExports")

#by segment
seg_delta %>%
    ggplot(aes(x=factor(FQ), y=Delta, group = Type, color = Type)) + 
    geom_line(aes(size = Type)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    xlab("FQ") +
    ylab("Change%") +
    scale_size_manual(values = c(AEG=1, ASD=1, AUT=1, COM=1, CON=1, DHC=1, INS=1,MachineExports = 1.5))

# Define UI for application that draws a histogram
ui <- fluidPage(
    selectInput(inputId = "Type", 
                label = "Choose a Segment", 
                multiple = T,
                selected = c("AEG", "ASD", "AUT", "COM", "CON", "DHC", "INS"),
                choices = unique(seg_delta$Type[!(seg_delta$Type == "MachineExports")])), 
    splitLayout(cellWidths = c("50%", "50%"),
                plotOutput("line"),
                plotOutput("lm")),
    verbatimTextOutput("summary")
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$line <- renderPlot({
        BySeg <- seg_delta %>%
            filter(Type %in% input$Type)
        
        ggplot(BySeg, aes(x=factor(FQ), y=Delta, color=Type, group=Type))+
            geom_line(size=0.6) + 
            theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
            xlab("FQ") +
            ylab("Value Change % (Rolling Mean)") +
            geom_line(data = mt, aes(x=factor(FQ), y=Delta, color = "MachineExports", group=Type),
                      size = 1.5)+
            ggtitle("Machine Tools Exports vs. ADI Revenue by Segment")
    })
    
    output$lm <- renderPlot({
        lm_data <- seg_delta %>%
            filter(Type %in% c(input$Type, "MachineExports")) %>%
            spread(Type, Delta)
        
        lm_data$total <- rowSums(lm_data[,3:(length(lm_data)-1)])
        
        ggplot(lm_data, aes(x=total, y=MachineExports)) + 
            geom_point(size = 1) +
            theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
            geom_smooth(method="lm") +
            xlab("Revenue Value Change % (Rolling Mean)") +
            ylab("Exports Change % (Rolling Mean)")+
            ggtitle("Revenue % vs. Exports %")
    })
    
    output$summary <- renderPrint({
        data <- seg_delta %>%
            filter(Type %in% c(input$Type, "MachineExports")) %>%
            spread(Type, Delta)
        
        data$x <- rowSums(data[,3:(length(data)-1)])
        
        fit <- lm(MachineExports~x, data=data)
        summary(fit)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
