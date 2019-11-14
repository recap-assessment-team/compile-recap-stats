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

source("~/.R/tony-utils.R")
# ------------------------------ #


# 4,838,430    2,453,742
nypl <- fread("~/data/parsed-htc/NYPL-RECAP-2.dat", colClasses="character",
              quote="", na.strings=c("", "NA", "NIL"))


# 4,622,980   3,296,623
cul <- fread("~/data/parsed-htc/CUL-RECAP-2.dat", colClasses="character",
             quote="", na.strings=c("", "NA", "NIL"),
             fill=TRUE)


# 3,367,792    2,200,337
pul <- fread("~/data/parsed-htc/PUL-RECAP-2.dat", colClasses="character",
             quote="", na.strings=c("", "NA", "NIL"))




cul[!is.na(vol), .(vol, barcode, scsbid)]




























nypl[, inst_has_item:="NYPL"]
cul[, inst_has_item:="CUL"]
pul[, inst_has_item:="PUL"]

setcolorder(nypl, c("inst_has_item"))
setcolorder(cul, c("inst_has_item"))
setcolorder(pul, c("inst_has_item"))

nypl

las <- fread("../step-2--fix-borrow-data/xactions-better.dat")
las[, barcode:=toupper(barcode)]

las <- las[item_owner %chin% c("CUL", "NYPL", "PUL")]

setkey(las, "barcode")



recap <-rbindlist(list(nypl, cul, pul))

recap[,.N]
# 12,829,202

recap[, barcode:=toupper(barcode)]
setkey(recap, "barcode")


recap[las] -> comb
recap[las, mult="first", nomatch=0L] -> comb
recap[las, mult="first"] -> comb

las[,.N]
comb[,.N]


comb[, .N, !is.na(inst_has_item)]
#     is.na      N
#    <lgcl>  <int>
# 1:   TRUE 123524
# 2:  FALSE  69274


comb[is.na(inst_has_item)]
comb[is.na(inst_has_item), .N]

comb %>% fwrite("results/las-xactions-and-info-joined.dat", sep="\t")


comb[order(req_date)]

# 2017-06-20
# 2019-09-20

