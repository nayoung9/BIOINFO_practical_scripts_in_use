#!/usr/bin/env Rscript

library(qvalue)

args <- commandArgs(TRUE)
input <- args[1]

p <- scan(input)
qobj <- qvalue(p)

cat(qobj$qvalues,sep="\n")
