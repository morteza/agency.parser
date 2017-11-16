# Compares 3-bin ERPs

subject = "grand"
rootDir = "~/Desktop"
expErpFile = paste(rootDir,"/",subject,"_spec_exp.txt",sep = "")
impErpFile = paste(rootDir,"/",subject,"_spec_imp.txt",sep = "")
freErpFile = paste(rootDir,"/",subject,"_spec_fre.txt",sep = "")

exp = read.table(expErpFile, header = TRUE)
imp = read.table(impErpFile, header = TRUE)
fre = read.table(freErpFile, header = TRUE)

limitTo = function(data, from, to=800) {
  data[which(data$time > from & data$time < to),]
}

low = 4
high = 7
exp = limitTo(exp, low, high)
imp = limitTo(imp, low, high)
fre = limitTo(fre, low, high)

erp = data.frame()

# F
plot(exp$time, exp$P, type = "l", col="red")
lines(imp$time, imp$P, type = "l", col="blue")
lines(fre$time, fre$P, type = "l", col = "green")

for (i in 1:length(exp$P)) {
  item = data.frame(typ = "exp", f = exp$P[i])
  erp = rbind(erp, item)
  item = data.frame(typ = "imp", f = imp$P[i])
  erp = rbind(erp, item)
  item = data.frame(typ = "fre", f = fre$P[i])
  erp = rbind(erp, item)
}

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

#for (i in 1:length(exp$Cz)) {
#  item = data.frame(typ = "exp", time = exp$time, f = (exp$Cz[i] + exp$C3[i] + exp$C4[i]) / 3)
#  erp = rbind(erp, item)
#  item = data.frame(typ = "imp", time = exp$time, f = (imp$Cz[i] + imp$C3[i] + imp$C4[i]) / 3)
#  erp = rbind(erp, item)
#  item = data.frame(typ = "fre", time = exp$time, f = (fre$Cz[i] + fre$C3[i] + fre$C4[i]) / 3)
#  erp = rbind(erp, item)
#}

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

#t.test(erp[erp$typ=="imp",]$f, erp[erp$typ=="exp",]$f)
