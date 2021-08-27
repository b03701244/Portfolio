library(zoo)

change_summ <- summ %>%
  group_by(Type, Fiscal_Mth) %>%
  summarise(Value = sum(Value)) %>%
  arrange(desc(Fiscal_Mth), .by_group = TRUE) %>%
  mutate(Delta = (Value - lead(Value))/lead(Value)*100)
#before smoothing
bf_mth <- change_summ %>%
  ggplot(aes(x=factor(Fiscal_Mth), y=Delta, group = Type, color = Type)) + 
  geom_line(size = 1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("Fiscal_Mth")

#calculate rm
change_summ$Delta_ra <- rollmean(change_summ$Delta,6, fill=NA)

change_summ2 <- change_summ %>%
  group_by(Fiscal_Mth, Type) %>%
  summarise(Delta_ra = mean(Delta_ra))%>%
  spread(Type, Delta_ra, fill = 0)

#after smoothing
af_mth <- change_summ2 %>%
  ggplot()+
  geom_line(aes(x=factor(Fiscal_Mth), y=Exports, group = 1, color = "Exports"), size=1) + 
  geom_line(aes(x=factor(Fiscal_Mth), y=Revenue, group = 1, color = "Revenue"), size=1) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("Fiscal_Mth") +
  ylab("Change%")

af_mth_reg <- ggplot(change_summ2, aes(y=Exports, x=Revenue))+
  geom_point() +
  geom_smooth(method="lm")  +
  xlab("Export Change%") +
  ylab("Revenue Change%")

#by qtr
change_summ2 <- summ %>%
  group_by(Type, FQ) %>%
  summarise(Value = sum(Value)) %>%
  arrange(desc(FQ), .by_group = TRUE) %>%
  mutate(Delta = (Value - lead(Value))/lead(Value)*100)

#before smoothing
bf_qtr <- change_summ2 %>%
  ggplot(aes(x=factor(FQ), y=Delta, group = Type, color = Type)) + 
  geom_line(size = 1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("FQ")

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
