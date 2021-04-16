#!/usr/local/bin//Rscript --vanilla


# ------------------------------ #
rm(list=ls())

options(echo=TRUE)
options(datatable.prettyprint.char=50)
options(width = 80)

args <- commandArgs(trailingOnly=TRUE)

library(colorout)
library(data.table)
library(magrittr)
library(stringr)
library(libbib)   # version 1.0 (on CRAN)

source("../dependencies/utils.R")
# ------------------------------ #

recap <- fread("../step-2--clean-and-enhance-bib-data/target/RECAP.dat")

recap[,subject_classification:=get_lc_call_subject_classification(lccall)]

recap[,subject_subclassification:=get_lc_call_subject_classification(lccall,
                                                                     subclassification=TRUE)]




recap %>% pivot("subject_classification", .N)

recap %>% pivot("subject_subclassification", .N)

recap %>% fwrite("./target/RECAP.dat", sep="\t", na="NA")

