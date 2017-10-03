# Compares 3-bin ERPs

subject = "nsh"
rootDir = "~/Desktop"
expErpFile = paste(rootDir,"/",subject,"_erp_explicit.txt",sep = "")
impErpFile = paste(rootDir,"/",subject,"_erp_implicit.txt",sep = "")
freErpFile = paste(rootDir,"/",subject,"_erp_free.txt",sep = "")

exp = read.table(expErpFile, header = TRUE)
imp = read.table(impErpFile, header = TRUE)
fre = read.table(freErpFile, header = TRUE)

limitDataTo = function(data, from, to=2000) {
  data[which(data$time > from & data$time < to),]
}

exp = limitTo(exp, 250, 700)
imp = limitTo(imp, 250, 700)
fre = limitTo(fre, 250, 700)

plot(exp$time, exp$Cz, type = "l", col="red")
lines(imp$time, imp$Cz, type = "l", col="blue")
lines(fre$time, fre$Cz, type = "l", col = "green")

a = data.frame()
for (i in 1:length(exp$Cz)) {
  item = data.frame(typ = "exp", cz = exp$Cz[i])
  a = rbind(a, item)
  item = data.frame(typ = "imp", cz = imp$Cz[i])
  a = rbind(a, item)
  item = data.frame(typ = "fre", cz = fre$Cz[i])
  a = rbind(a, item)
}
write()

res = aov(data = a, cz ~ typ)
summary(res)
