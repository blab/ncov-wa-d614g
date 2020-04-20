
library(ggplot2)
library(dplyr)
options(na.action=na.omit)


# Load data:

df_uw = read_tsv(file = '../results/2020414_df.tsv')
# Modify variables:

df_uw$clade[df_uw$clade =='S'] = 'D'
df_uw$age_bin = factor(df_uw$age_bin, levels = c("10-20", "20-30", "30-40", "40-50", "50-60", "60-70", "70-80", "80-90", "over 90"), ordered = TRUE)
df_uw$clade = factor(df_uw$clade, levels = c("D", "G"))
df_uw$age[df_uw$age_bin == '10-20'] = 15
df_uw$age[df_uw$age_bin == '20-30'] = 25
df_uw$age[df_uw$age_bin == '30-40'] = 35
df_uw$age[df_uw$age_bin == '40-50'] = 45
df_uw$age[df_uw$age_bin == '50-60'] = 55
df_uw$age[df_uw$age_bin == '60-70'] = 65
df_uw$age[df_uw$age_bin == '70-80'] = 75
df_uw$age[df_uw$age_bin == '80-90'] = 85
df_uw_wa = filter(df_uw, division == 'Washington')
df_wa = na.omit(df_uw_wa)


table(df_uw$age_bin, df_uw$clade)
table(df_uw_wa$age_bin, df_uw_wa$clade)
table(df_wa$age_bin, df_wa$clade)



t.test(df_wa$avg_ct~df_wa$clade)
t.test(df_wa$age~df_wa$clade)


#Output plots
ct = ggplot(df_wa, aes(x=clade, y=avg_ct), na.rm=TRUE) + 
  geom_violin(alpha=0.7, aes(color=clade, fill=clade)) + 
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  scale_color_manual(values=c('#4C90C0', '#AEBD50'), breaks=c('D', 'G')) +
  stat_summary(fun.data="mean_sdl", geom="pointrange") +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Average Ct") +
  xlab("Clade") +
  labs(caption = "D: Mean Ct = 20.02,  G: Mean Ct = 18.52,   p-value = 0.00002")

ct

age = ggplot(df_wa, mapping = aes(x=clade, y=age_bin, color=clade, fill=clade)) + 
  geom_dotplot(binaxis="y", stackdir="center", binwidth=0.17) + 
  scale_color_manual(values=c('#4C90C0', '#AEBD50'), breaks=c('D', 'G')) +
  scale_fill_manual(values=c('#4C90C0', '#AEBD50')) +
  theme_minimal() +
  theme(text = element_text(family = "NimbusSan", size = 10)) +
  ylab("Age") +
  xlab("Clade") +
  labs(caption = "D: Mean age = 56.88,  G: Mean age = 50.15,   p-value = 0.0009")

age