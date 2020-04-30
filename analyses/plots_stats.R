library(tidyverse)
library(forecast)

# Load data:
df = read_tsv(file = '../results/2020414_df.tsv')

# Subset to Washington only
df_wa = filter(df, division == 'Washington')

# Missing values
sum(is.na(df_wa))
sum(is.na(df_wa$clade))
df_wa$strain[is.na(df_wa$clade)] #All of these are listed in config/exclude in ncov build.
df_wa=drop_na(df_wa)
 
# Modify variables:
distinct(df_wa, age_bin)

df_wa$clade[df_wa$clade =='S'] = 'D'

df_wa$age_bin = factor(df_wa$age_bin, levels = c("10-20", "20-30", "30-40", "40-50", "50-60", "60-70", "70-80", "80-90", "over 90"), ordered = TRUE)
df_wa$clade = factor(df_wa$clade, levels = c("D", "G"))


df_wa$age[df_wa$age_bin == '10-20'] = 15
df_wa$age[df_wa$age_bin == '20-30'] = 25
df_wa$age[df_wa$age_bin == '30-40'] = 35
df_wa$age[df_wa$age_bin == '40-50'] = 45
df_wa$age[df_wa$age_bin == '50-60'] = 55
df_wa$age[df_wa$age_bin == '60-70'] = 65
df_wa$age[df_wa$age_bin == '70-80'] = 75
df_wa$age[df_wa$age_bin == '80-90'] = 85
df_wa$age[df_wa$age_bin == 'over 90'] = 91 #Better to be conservative


# Exploring data
summary(df_wa)
table(df_wa$age_bin_factor, df_wa$clade_factor)
hist_date = ggplot(df_wa, aes(x=date, color=clade, fill=clade)) + 
  geom_bar(position = position_stack()) + 
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_color_manual(values=c('#4C90C0', '#AEBD50')) +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Count") +
  xlab("Date")
hist_date

# T tests
t.test(df_wa$avg_ct~df_wa$clade)
t.test(df_wa$avg_ct[df_wa$date > as.Date("2020-03-09")]~df_wa$clade[df_wa$date > as.Date("2020-03-09")])

t.test(df_wa$age~df_wa$clade)
t.test(df_wa$age[df_wa$date > as.Date("2020-03-09")]~df_wa$clade[df_wa$date > as.Date("2020-03-09")])

# Wilcoxon signed-rank test
wilcox.test(formula = avg_ct ~ clade, data= df_wa, alternative = "two.sided")
wilcox.test(formula = avg_ct ~ clade, data= df_wa[df_wa$date > as.Date("2020-03-09"), ], alternative = "two.sided")

wilcox.test(formula = age ~ clade, data= df_wa, alternative = "two.sided")
wilcox.test(formula = age ~ clade, data= df_wa[df_wa$date > as.Date("2020-03-09"), ], alternative = "two.sided")



# Plots
ct = ggplot(df_wa, aes(x=clade, y=avg_ct), na.rm=TRUE) + 
  geom_violin(alpha=0.7, aes(color=clade, fill=clade)) + 
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_color_manual(values=c('#4C90C0', '#AEBD50')) +
  stat_summary(fun.data="mean_sdl", geom="pointrange") +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Average Ct") +
  xlab("Clade") +
  labs(caption = "D: Mean Ct = 19.89,  G: Mean Ct = 18.57,   t-test p-value = 0.000009,   Wilcoxon test p-value = 0.000008")

ct_later = ggplot(df_wa[df_wa$date > as.Date("2020-03-09"), ], aes(x=clade, y=avg_ct), na.rm=TRUE) + 
  geom_violin(alpha=0.7, aes(color=clade, fill=clade)) + 
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_color_manual(values=c('#4C90C0', '#AEBD50')) +
  stat_summary(fun.data="mean_sdl", geom="pointrange") +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Average Ct") +
  xlab("Clade") +
  labs(caption = "D: Mean Ct = 19.57,  G: Mean Ct = 18.52,  t-test p-value = 0.0005,  Wilcoxon test p-value = 0.0004 ") +
  labs(subtitle = "UW sequences: March 10-24")
ct_later

age = ggplot(df_wa, mapping = aes(x=clade, y=age_bin, color=clade, fill=clade)) + 
  geom_dotplot(binaxis="y", stackdir="center", binwidth=0.17) + 
  scale_color_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Age") +
  xlab("Clade") +
  labs(caption = "D: Mean age = 57.41,  G: Mean age = 50.75,   t-test p-value = 0.0002,  Wilcoxon test p-value = 0.0003")

age_later = ggplot(df_wa[df_wa$date > as.Date("2020-03-09"), ], mapping = aes(x=clade, y=age_bin, color=clade, fill=clade)) + 
  geom_dotplot(binaxis="y", stackdir="center", binwidth=0.17, position = position_jitter(width = 0, height=0.0)) + 
  scale_color_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Age") +
  xlab("Clade") +
  labs(caption = "D: Mean age = 55.57,  G: Mean age = 50.63,   t-test p-value = 0.006,  Wilcoxon test p-value = 0.009") +
  labs(subtitle = "UW sequences: March 10-24")
age_later

week_labels = c("1" = "Mar 3-9", "2" = "Mar 10-16", "3" = "Mar 17-24")

ct_by_week = ggplot(df_wa, mapping = aes(x=clade, y=avg_ct), na.rm=TRUE) + 
  geom_violin(alpha=0.7, aes(color=clade, fill=clade)) + 
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_color_manual(values=c('#4C90C0', '#AEBD50')) +
  stat_summary(fun.data="mean_sdl", geom="pointrange") +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Average Ct") +
  xlab("Clade") +
  facet_wrap(~ week, labeller=labeller(week = week_labels))
ct_by_week

age_by_week = ggplot(df_wa, mapping = aes(x=clade, y=age_bin, color=clade, fill=clade)) + 
  geom_dotplot(binaxis="y", stackdir="center", binwidth=0.1, position = position_jitter(width =0, height = 0.35)) + 
  scale_color_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Age") +
  xlab("Clade") +
  facet_wrap(~ week, labeller=labeller(week = week_labels))

age_by_week

# Which sequences have EHR available?

ehr = read_tsv(file = '../data/sequences_w_ehr.tsv')
ehr = cbind(ehr, ehr = c(1))
df_wa = left_join(df_wa, ehr, by = 'strain')
df = left_join(df, ehr, by = 'strain')
sum(df$ehr, na.rm = TRUE)
sum(df_wa$ehr, na.rm = TRUE)
sum(ehr$strain)

no_seqs = anti_join(ehr, df, by = 'strain')
no_seqs$strain

table(df_wa$clade[df_wa$date > as.Date("2020-03-09")], df_wa$ehr[df_wa$date > as.Date("2020-03-09")])








# Regressions
df_wa$time = df_wa$date - as.Date("2020-03-03")
df_wa$week[df_wa$date < as.Date("2020-03-10")] = 1 
df_wa$week[df_wa$date < as.Date("2020-03-17") & df_wa$date > as.Date("2020-03-09")] = 2
df_wa$week[df_wa$date > as.Date("2020-03-16") & df_wa$date < as.Date("2020-03-24")] = 3
df_wa$week[df_wa$date == as.Date("2020-03-24")] = 4
df_wa$week_factor = factor(df_wa$week, levels = c(1, 2, 3, 4))

lreg_age_time = lm(age ~ clade + avg_ct + week, data = df_wa[df_wa$date > as.Date("2020-03-09"), ])

summary(lreg_age_time)
checkresiduals(lreg_age_time)
df_wa[df_wa$date > as.Date("2020-03-09"), "Residuals"] = residuals(lreg_age_time)

p1 <- ggplot(df_wa, aes(x=clade, y=Residuals)) +
  geom_point()
p2 <- ggplot(df_wa, aes(x=avg_ct, y=Residuals)) +
  geom_point()
p3 <- ggplot(df_wa, aes(x=time, y=Residuals)) +
  geom_point(alpha=0.3)
gridExtra::grid.arrange(p2, p3, p4, nrow=2)


cbind(Fitted = fitted(lreg_age_time),
      Residuals=residuals(lreg_age_time)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Fitted, y=Residuals)) + geom_point()

# Linear regression on Ct
lreg_ct = lm(avg_ct ~ clade + age, data = df_wa[df_wa$date > as.Date("2020-03-09"), ])

summary(lreg_ct)
checkresiduals(lreg_ct)
df_wa[df_wa$date > as.Date("2020-03-09"), "Residuals"] = residuals(lreg_ct)

p1 <- ggplot(df_wa, aes(x=clade, y=Residuals)) +
  geom_point(alpha=0.2)
p2 <- ggplot(df_wa, aes(x=age, y=Residuals)) +
  geom_point(alpha=0.2)
p3 <- ggplot(df_wa, aes(x=date, y=Residuals)) +
  geom_point(alpha=0.2)

gridExtra::grid.arrange(p1,p2, p3, nrow=1)


cbind(Fitted = fitted(lreg_ct),
      Residuals=residuals(lreg_ct)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Fitted, y=Residuals)) + geom_point()


ggplot(df_wa[df_wa$date > as.Date("2020-03-09"), ], aes(x = time, y = age)) +
  geom_point(alpha=0.1)

lin_age_time = glm(age ~ time, data = df_wa[df_wa$date > as.Date("2020-03-09"), ])
summary(lin_age_time)

# Linear regression on clade

lreg_clade = glm(clade ~ age - 1, data = df_wa[df_wa$date > as.Date("2020-03-09"), ], family = "binomial")

summary(lreg_clade)
checkresiduals(lreg_clade)
df_wa[df_wa$date > as.Date("2020-03-09"), "Residuals"] = residuals(lreg_clade)

p1 <- ggplot(df_wa, aes(x=avg_ct, y=Residuals)) +
  geom_point(alpha=0.2)
p2 <- ggplot(df_wa, aes(x=age, y=Residuals)) +
  geom_point(alpha=0.2)
p3 <- ggplot(df_wa, aes(x=date, y=Residuals)) +
  geom_point(alpha=0.2)

gridExtra::grid.arrange(p1,p2, p3, nrow=1)


cbind(Fitted = fitted(lreg_clade),
      Residuals=residuals(lreg_clade)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Fitted, y=Residuals)) + geom_point()


# OLS on age

ols_age = polr(age_bin ~ clade + avg_ct + time, data = df_wa[df_wa$date > as.Date("2020-03-09"), ], Hess = TRUE)
summary(ols_age)
#checkresiduals(ols_age)
df_wa[df_wa$date > as.Date("2020-03-09"), "Residuals"] = deviance(ols_age)

p1 <- ggplot(df_wa, aes(x=clade, y=Residuals)) +
  geom_point(alpha=0.2)
p2 <- ggplot(df_wa, aes(x=avg_ct, y=Residuals)) +
  geom_point(alpha=0.2)
p3 <- ggplot(df_wa, aes(x=date, y=Residuals)) +
  geom_point(alpha=0.2)

gridExtra::grid.arrange(p1,p2, p3, nrow=1)


cbind(Fitted = fitted(ols_age),
      Residuals=deviance(ols_age)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Fitted, y=Residuals)) + geom_point()





ctable_ols_age = coef(summary(ols_age))

p_ols_age = pnorm(abs(ctable_ols_age[, "t value"]), lower.tail = FALSE) * 2
ctable_ols_age = cbind(ctable_ols_age, "p value" = p_ols_age)
ctable_ols_age
ci_ols_age = confint(ols_age)
exp(cbind(OR = coef(ols_age), ci_ols_age))
