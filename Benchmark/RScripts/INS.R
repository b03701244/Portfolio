DAR <- read_csv("DAR_Historic.csv")
DAR$Revenue <- gsub("[],\\)]", "",DAR$Revenue)
DAR$Revenue <- gsub("^\\(", "-",DAR$Revenue)
DAR$Revenue <- gsub("\\$", "",DAR$Revenue) %>% as.numeric()
#find only INS
DAR_ins <- DAR[DAR$End_Mkt_Segment=="INS",]
DAR_ins <-  DAR_ins %>%
  group_by(Fiscal_Mth) %>%
  summarise(Revenue = sum(Revenue))

by_seg <- DAR_ins %>%
  left_join(table) %>%
  group_by(FQ) %>%
  summarise(Exports = sum(Exports), Revenue = sum(Revenue)) %>%
  gather("Type", "Value", Exports:Revenue) %>%
  na.omit()%>%
  ungroup()

#copied from previous
summ <- DAR_ins %>%
  left_join(table) %>%
  group_by(FQ) %>%
  summarise(Exports = sum(Exports), Revenue = sum(Revenue)) %>%
  gather("Type", "Value", Exports:Revenue) %>%
  na.omit()%>%
  ungroup()

#by qtr
change_summ2 <- summ %>%
  group_by(Type, FQ) %>%
  summarise(Value = sum(Value)) %>%
  arrange(desc(FQ), .by_group = TRUE) %>%
  mutate(Delta = (Value - lead(Value))/lead(Value)*100)

#calculate rm qtr
change_summ2$Delta_ra <- rollmean(change_summ2$Delta,6, fill=NA)

change_summ2 <- change_summ2 %>%
  na.omit() %>%
  group_by(FQ, Type) %>%
  dplyr::summarise(Delta_ra = mean(Delta_ra))

#after smoothing qtr
af_qtr <- change_summ2 %>%
  ggplot(aes(x=factor(FQ), y=Delta_ra, group = Type, color = Type)) + 
  geom_line(size = 1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("FQ") +
  ylab("Change%")
lm_change <- change_summ2 %>%
  spread(Type, Delta_ra)

af_qtr_reg <- lm_change %>%
  ggplot(aes(x=Revenue, y=Exports)) + 
  geom_point(size = 1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  geom_smooth(method="lm") +
  xlab("Revenue Change %") +
  ylab("Exports Change %%")

fit <- lm(lm_change$Exports~lm_change$Revenue)
summary(fit)