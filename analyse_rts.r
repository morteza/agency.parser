
# Run this: source('~/Desktop/analyse_rts.r', echo=TRUE)
setwd("~/Desktop/data/")

subjects = c("ach","aka","akh", "bah", "fhe", "mhe", "mkh", "nkh", "nsh", "rho", "rsa", "sa1", "sa2", "sfa", "sja")
subject = readline("Enter subject code: ")

remove_outliers = function(x, group, ...) {
  x = x[x$group == group,]
  y = x
  qnt <- quantile(y$rt, probs=c(.25, .75), na.rm = TRUE, ...)
  H <- 1.5 * IQR(y$rt, na.rm = TRUE)
  y[x$rt < (qnt[1] - H),] <- NA
  y[x$rt > (qnt[2] + H),] <- NA
  y[complete.cases(y),]
}

analyze = function(subject) {

}


# for (s in subjects) {
#  print(s)
#  analyze(s)
#}

print("Analysing...")
setwd("~/Desktop/data/")

# read.csv(file.choose())
#rts = read.csv(paste(subject, "/", subject, "_conditions_rows.csv", sep = ""))
rts = read.csv("conditions_rows.csv")

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

setwd("~/Desktop/data/figs/")
#png(filename=paste(subject, "boxplot.png", sep = "_"))
png(filename="boxplot.png")
# ggpubr - boxplot
ggboxplot(rts, x = "group", y = "rt", 
          color = "group", palette = c("#00AFBB", "#E7B800", "#FC4E07", "#DD0ED7"),
          order = c("exp_cor", "fre_ctl", "fre_exp", "imp_cor"),
          ylab = "Reaction Time", xlab = "Group", title = paste(subject, "boxplot"))
dev.off()

# ggpubr - mean plot
#png(filename=paste(subject, "mean_se.png", sep = "_"))
png(filename="mean_se.png")
ggline(rts, x = "group", y = "rt", 
       add = c("mean_se", "jitter"), #c("mean_se", "jitter"), 
       order = c("exp_cor", "fre_ctl", "fre_exp", "imp_cor"),
       ylab = "Reaction Time", xlab = "Group", title = paste(subject, "mean_se"))
dev.off()

# R - Box plot
#boxplot(rt ~ group, data = rts,
#        xlab = "Group", ylab = "Reaction Time",
#        frame = FALSE, col = c("#00AFBB", "#E7B800", "#FC4E07", "#DD0ED7"))

# gplot - mean plot
# library("gplots")
#plotmeans(rt ~ group, data = rts, frame = FALSE,
#          xlab = "Group", ylab = "Reaction Time",
#          main="Mean Plot with 95% CI") 

# ANOVA (one-way)
res.aov = aov(rt ~ group+subject, data = rts)
# Summary of the analysis
summary(res.aov)
# Plot for Homogeneity of variances
# plot(res.aov, 1)
#TukeyHSD(res.aov)
# Non parametric Kruskal-Wallies
#kruskal.test(rt ~ group, data = rts)

