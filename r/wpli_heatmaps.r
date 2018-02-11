library(gplots)
library(reshape2)

subjects = c("ach","aka","akh","bah","fhe","mhe","mkh","nkh","nsh","rho","rsa","sa1","sa2","sfa","sja")
conditions = c("impl","expl","free")
plt = colorRampPalette(c("red","yellow","green"))(n=299)
chans = c("Fp1","Fp2","F7","F3","Fz","F4","F8","T3","C3","Cz","C4","T4","T5","P3","Pz","P4","T6","O1","O2")

for (subj in subjects) {
  for (cond in conditions) {
    wpli_file = paste("~/Desktop/sift_data/wpli/agency_wpli_all_chans/",subj,"_",cond,".csv",sep = "") 
    wpli = read.table(wpli_file,sep=",")
    wpli = round(as.matrix(wpli),2)
    rownames(wpli) <- chans
    colnames(wpli) <- chans
    png(width = 1000, height = 1000, filename = paste("~/Desktop/sift_data/figures/agency_wpli_all_chans_r_heatmaps/",subj,"_",cond,".png", sep = ""))
    heatmap.2(
      wpli,
      cellnote = wpli,
      dendrogram="none" ,
      notecol = "black",
      col = plt,
      Colv="NA",
      Rowv = "NA",
      breaks = seq(-1,1,length.out = 300),
      key.title = "Density",
      trace="none")
    dev.off()
    #melted_wpli = melt(wpli)
    #melted_wpli$chans = 1:19
    #ggplot(melted_wpli, aes(x=chans, y=Var2, fill=value)) + geom_tile()
  }
}