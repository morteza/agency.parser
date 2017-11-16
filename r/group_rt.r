
# Run this: source('~/Desktop/analyse_rts.r', echo=TRUE)
setwd("~/Desktop/data/misc/")

remove_outliers = function(x, cnd) {
  x = x[as.character(x$condition) == cnd,]
  y = x

  qnt <- quantile(x$rt, probs=c(.25, .75), na.rm = TRUE)
  H <- 1.5 * IQR(x$rt, na.rm = TRUE)
  y[x$rt < (qnt[1] - H),] <- NA
  y[x$rt > (qnt[2] + H),] <- NA
  y[x$rt > 1.0,] <- NA
  y[complete.cases(y),]
}

analyze = function(subject) {

}


# for (s in subjects) {
#  print(s)
#  analyze(s)
#}

print("Analysing...")
setwd("~/Desktop/data/misc/")

# read.csv(file.choose())
#rts = read.csv(paste(subject, "/", subject, "_conditions_rows.csv", sep = ""))
rts = read.csv("conditions_rows.csv",stringsAsFactors = FALSE)
hyp = rts[rts$group=="hyp",]
nonhyp = rts[rts$group=="nonhyp",]

rts = rts[rts$group=="nonhyp",]
rts = rbind(remove_outliers(rts, "fre_ctl"),
            remove_outliers(rts, "fre_exp"),
            remove_outliers(rts, "exp_cor"),
            remove_outliers(rts, "imp_cor"))

#set.seed(1234)
#library(dplyr)
#dplyr::sample_n(rts, 10)

#levels(rts$group)

#group_by(rts, group) %>%
#  summarise(
#    count = n(),
#    mean = mean(rt, na.rm = TRUE),
#    sd = sd(rt, na.rm = TRUE)
#  )

library(ggpubr)

mean(rts[rts$condition=="fre_ctl",]$rt)

setwd("~/Desktop/data/misc/behavioral_figs/new/")
#png(filename=paste(subject, "boxplot.png", sep = "_"))
png(filename="boxplot.png")
# ggpubr - boxplot
ggboxplot(rts, x = "condition", y = "rt", 
          color = "condition", palette = c("#00AFBB", "#E7B800", "#FC4E07", "#DD0ED7"),
          order = c("exp_cor", "fre_ctl", "fre_exp", "imp_cor"),
          ylab = "Reaction Time", xlab = "Condition", title = paste("Non-Hypnotized Subjects (nonhyp)"))
dev.off()

# ggpubr - mean plot
#png(filename=paste(subject, "mean_se.png", sep = "_"))
png(filename="mean_se.png")
ggline(rts, x = "condition", y = "rt", 
       add = c("mean_se"),
       plot_type = "b",
       order = c("exp_cor", "fre_ctl", "fre_exp", "imp_cor"),
       ylab = "Reaction Time", xlab = "Condition", title = paste("Non-Hypnotized (nonhyp) Group"))
dev.off()

# R - Box plot
#boxplot(rt ~ condition, data = rts,
#        xlab = "Group", ylab = "Reaction Time",
#        frame = FALSE, col = c("#00AFBB", "#E7B800", "#FC4E07", "#DD0ED7"))

# gplot - mean plot
# library("gplots")
#plotmeans(rt ~ condition, data = rts, frame = FALSE,
#          xlab = "Group", ylab = "Reaction Time",
#          main="Mean Plot with 95% CI") 

# ANOVA
rts$subject = as.factor(rts$subject)
fit = aov(rt~condition+Error(subject),data=rts)
#res.aov = aov(rt ~ group*condition*subject, data = rts)
# Summary of the analysis
#summary(res.aov)
# Plot for Homogeneity of variances
# plot(res.aov, 1)
#TukeyHSD(res.aov)
# Non parametric Kruskal-Wallies
#kruskal.test(rt ~ group, data = rts)


# RT
hyp = c(12,1,2,45,8,2,0,1,5,1);
nonhyp = c(47,42,21,35,54)

t.test(nonhyp,hyp,paired = FALSE, alternative = "greater",var.equal = TRUE, conf.level = 0.95)
