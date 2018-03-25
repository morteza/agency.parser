study = "agency_wpli_all_chans_theta_band";

library(reshape2);
all_subjects = c("ach","aka","akh","bah","fhe","mhe","mkh","nkh","nsh","rho","rsa","sa1","sa2","sfa","sja");
subjects = c("aka","akh","fhe","nkh","nsh","rho","rsa","sa1","sa2","sfa","sja");
conditions = c("impl","expl","free");
chans = c("Fp1","Fp2","F7","F3","Fz","F4","F8","T3","C3","Cz","C4","T4","T5","P3","Pz","P4","T6","O1","O2");

#MIXED all_wpli = list(list(),list(),list())
#MIXED names(all_wpli) = conditions
all_wpli = list();

for (subj in subjects) {
  for (cond in conditions) {
    wpli_file = paste("~/Desktop/sift_data/wpli/",study,"/",subj,"_",cond,".csv",sep = "") 
    wpli = read.table(wpli_file,sep=",")
    wpli = round(as.matrix(wpli),2)
    rownames(wpli) <- chans
    colnames(wpli) <- chans
    wpli = melt(wpli, varnames = c("From","To"), value.name = c("wPLI"));
    wpli[["condition"]] = factor(cond);
    wpli[["subject"]] = factor(subj);
    # collapse electrodes into connections
    wpli$connection = apply(wpli[,c("From","To")],1 ,paste ,collapse = "")
    wpli$connection = factor(wpli$connection)
    
    #MIXED all_wpli[[cond]] = rbind(all_wpli[[cond]], wpli)
    wpli = wpli[,c(-1,-2)]
    all_wpli = rbind(all_wpli, wpli)
    #ggplot(melted_wpli, aes(x=chans, y=Var2, fill=value)) + geom_tile()
  }
}
res = aov(wPLI ~ (condition*connection) + Error(subject), all_wpli);
#tky_res = TukeyHSD(res)
summary(res)
