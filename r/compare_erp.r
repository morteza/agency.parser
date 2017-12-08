# Compares 3-bin ERPs

subject = "grand"
dv = "_spec"
dv = ""
rootDir = "~/Desktop/data/misc/studies"
expErpFile = paste(rootDir,"/",subject,dv,"_exp.txt",sep = "")
impErpFile = paste(rootDir,"/",subject,dv,"_imp.txt",sep = "")
freErpFile = paste(rootDir,"/",subject,dv,"_fre.txt",sep = "")

exp = read.table(expErpFile, header = TRUE)
imp = read.table(impErpFile, header = TRUE)
fre = read.table(freErpFile, header = TRUE)

limitTo = function(data, from, to=800) {
  data[which(data$time > from & data$time < to),]
}

low = 320
high = 420
exp = limitTo(exp, low, high)
imp = limitTo(imp, low, high)
fre = limitTo(fre, low, high)

erp = data.frame()

# F
plot(exp$time, exp$Fz, type = "l", col="red")
lines(imp$time, imp$Fz, type = "l", col="blue")
lines(fre$time, fre$Fz, type = "l", col = "green")

 for (i in 1:length(exp$Fz)) {
   erp = rbind(erp, data.frame(
     typ = "exp", 
     time = exp$time, 
     f = (exp$F3[i] + exp$Fz[i] + exp$F4[i] + exp$F7[i] + exp$F8[i])/5
   ))
   erp = rbind(erp, data.frame(
    typ = "imp",
    time = imp$time,
    f = (imp$F3[i] + imp$Fz[i] + imp$F4[i] + imp$F7[i] + imp$F8[i])/5
  ))
  erp = rbind(erp, data.frame(
    typ = "fre",
    time = fre$time,
    f = (fre$F3[i] + fre$Fz[i] + fre$F4[i] + fre$F8[i] + fre$F7[i])/5
  ))
}

# F - Spec Power
# for (i in 1:length(exp$F)) {
#   erp = rbind(erp, data.frame(
#     typ = "exp",time = exp$time,
#     f = exp$F[i]
#   ))
#   erp = rbind(erp, data.frame(
#     typ = "imp",time = imp$time,
#     f = imp$F[i]
#   ))
#   erp = rbind(erp, data.frame(
#     typ = "fre",time = fre$time,
#     f = fre$F[i]
#   ))
# }

# P
# plot(exp$time, exp$Pz, type = "l", col="red",xlab = "Timestamp", ylab = "Pz (uV)")
# lines(imp$time, imp$Pz, type = "l", col="blue")
# lines(fre$time, fre$Pz, type = "l", col = "green")
# 
# for (i in 1:length(exp$Pz)) {
#   item = data.frame(typ = "exp", f = (exp$Pz[i] + exp$P3[i] + exp$P4[i]) / 3)
#   erp = rbind(erp, item)
#   item = data.frame(typ = "imp", f = (imp$Pz[i] + imp$P3[i] + imp$P4[i]) / 3)
#   erp = rbind(erp, item)
#   item = data.frame(typ = "fre", f = (fre$Pz[i] + fre$P3[i] + fre$P4[i]) / 3)
#   erp = rbind(erp, item)
# }

# C

# for (i in 1:length(exp$Cz)) {
#   item = data.frame(typ = "exp", time = exp$time, f = (exp$Cz[i] + exp$C3[i] + exp$C4[i]) / 3)
#   erp = rbind(erp, item)
#   item = data.frame(typ = "imp", time = exp$time, f = (imp$Cz[i] + imp$C3[i] + imp$C4[i]) / 3)
#   erp = rbind(erp, item)
#   item = data.frame(typ = "fre", time = exp$time, f = (fre$Cz[i] + fre$C3[i] + fre$C4[i]) / 3)
#   erp = rbind(erp, item)
# }

#plot(exp$time, exp$Cz, type = "l", col="red",xlab = "Timestamp", ylab = "Cz (uV)", ylim = c(-1.0,2.0))
#lines(imp$time, imp$Cz, type = "l", col="blue")
#lines(fre$time, fre$Cz, type = "l", col = "green")


# N100
# plot(exp$time,  (exp$Cz + exp$Pz + exp$Fz), type = "l", col="red",xlab = "Timestamp", ylab = "average(Fz,Cz,Pz) (uV)",ylim = c(-1,1))
# lines(imp$time, (imp$Cz + imp$Pz + imp$Fz), type = "l", col="blue")
# lines(fre$time, (fre$Cz + fre$Pz + fre$Fz), type = "l", col = "green")
# 
# for (i in 1:length(exp$Pz)) {
#   item = data.frame(typ = "exp", f = (exp$Pz[i] + exp$Cz[i] + exp$Fz[i]))
#   erp = rbind(a, item)
#   item = data.frame(typ = "imp", f = (imp$Pz[i] + imp$Cz[i] + imp$Fz[i]))
#   erp = rbind(a, item)
#   item = data.frame(typ = "fre", f = (fre$Pz[i] + fre$Cz[i] + fre$Fz[i]))
#   erp = rbind(a, item)
# }

res = aov(data = erp, f ~ typ)
summary(res)
TukeyHSD(res)
summary(erp[erp$typ=="imp",]$f);sd(erp[erp$typ=="imp",]$f)
summary(erp[erp$typ=="exp",]$f);sd(erp[erp$typ=="exp",]$f)
summary(erp[erp$typ=="fre",]$f);sd(erp[erp$typ=="fre",]$f)

# Power Spec
#summary(imp$F);sd(imp$F)
#summary(exp$F);sd(exp$F)
#summary(fre$F);sd(fre$F)
#t.test(erp[erp$typ=="imp",]$f, erp[erp$typ=="exp",]$f)
