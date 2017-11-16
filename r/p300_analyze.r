print("Analyzing grand ERP for P300")

peaks = read.table("/Users/morteza/Desktop/all_mean_amp.txt", header = TRUE)

peaks = peaks[peaks$bini<3,]

peaks$bini = as.factor(peaks$bini)
peaks$binlabel = as.factor(peaks$binlabel)
peaks$ERPset = as.factor(peaks$ERPset)
peaks$chlabel = as.factor(peaks$chlabel)

#t.test(peaks[peaks$bini==2,]$value,peaks[peaks$bini==3,]$value)
res = aov(data = peaks, formula = value ~ binlabel + (ERPset))
summary(res)

#exp = read.table("/Users/morteza/Desktop/nsh_erp_Explicit Instruction (Correct).txt", header = TRUE)
#imp = read.table("/Users/morteza/Desktop/nsh_erp_Implicit Suggestion (Correct) .txt", header = TRUE)

#exp = exp[exp$time>=200 & exp$time<=400,]
#imp = imp[imp$time>=200 & imp$time<=400,]
#tstat = t.test(exp$Pz, imp$Pz)