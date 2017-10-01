setwd('~/Desktop/data/misc/r') 
groups.counts = read.table(file='groups_counts.txt',header=FALSE)
colnames(groups.counts) = c("subject","exp","imp","fre","ctl","incorrect")


# Imports ERP data for all subjects
importERPData <- function(path){
  files = list.files(path = path, pattern = "\\.csv$", full.names = T)
  results = c()
  
  for (f in files){
    subjERP = read.table(f, header = T)
    subjERP$subject = as.character(f)
    subjERP$t = rownames(subjERP)
    results = rbind(results, subjERP)
    print(subjERP)
  }
  return(results)
}