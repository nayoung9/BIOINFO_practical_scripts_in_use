#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
input <- args[1]
data <- read.csv(input, header = F)
pv <- c()
GOterm <- c()
for (i in 1:length(data$V1)){
	if (data$V1[i] == 0 ) {
		pv[i] = 1
		next;
	}
	GO = as.character(data$V1[i])
	in1 = data$V2[i] - 1
	in2 = data$V4[i]
	in3 = data$V5[i]-in2
	in4 = data$V3[i]
	GOterm[i] = GO
	pv[i] = 1 - phyper(in1,in2,in3,in4)
}

cat(paste(pv,GOterm,sep="\t"),sep = "\n")
