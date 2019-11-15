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

source("bibcodes.R")


# 4,838,430    2,453,742
nypl <- fread("~/data/compile-recap-stats-data/parsed-htc/NYPL-RECAP.dat",
              colClasses="character", quote="", na.strings=c("", "NA", "NIL"))


# 4,622,980   3,296,623
cul <- fread("~/data/compile-recap-stats-data/parsed-htc/CUL-RECAP.dat",
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"),
             fill=TRUE)

# 3,367,792    2,200,337
pul <- fread("~/data/compile-recap-stats-data/parsed-htc/PUL-RECAP.dat",
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"))



##################
##     LCCN     ##
##################
nypl[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2019)]
cul[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2019)]
pul[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2019)]






OLDORDER <- names(nypl)





##################
##     ISBN     ##
##################
nypl[, tmp:=sprintf("nypl-%s-%s", barcode, scsbid)]
# only one
nypl <- nypl[!duplicated(tmp)]

cul[, tmp:=sprintf("cul-%s-%s", barcode, scsbid)]
# only five
# cul[,.N]
# uniqueN(cul[, .(tmp)])
cul <- cul[!duplicated(tmp)]

pul[, tmp:=sprintf("pul-%s-%s", barcode, scsbid)]
# NONE
# pul <- pul[!duplicated(tmp)]

nypl[!is.na(isbn), .(tmp, isbn)] -> one
cul[!is.na(isbn), .(tmp, isbn)] ->  two
pul[!is.na(isbn), .(tmp, isbn)] ->  three

comb <- rbindlist(list(one, two, three))

library(tidyr)
comb %>% separate_rows(isbn, sep=";") -> comb

options(warn=1)
comb[, fixedisbn:=normalize_isbn(isbn, convert.to.isbn.13=TRUE)]

comb

uniqueN(comb[, .(isbn)])
uniqueN(comb[, .(fixedisbn)])

comb[, .(isbn=paste(unique(fixedisbn), collapse=";")), tmp] -> betterisbns



##################
##     ISBN     ##
##################
nypl[!is.na(issn), .(tmp, issn)] -> one
cul[!is.na(issn), .(tmp, issn)] ->  two
pul[!is.na(issn), .(tmp, issn)] ->  three

comb <- rbindlist(list(one, two, three))

library(tidyr)
comb %>% separate_rows(isbn, sep=";") -> comb

options(warn=1)
comb[, fixedisbn:=normalize_isbn(isbn, convert.to.isbn.13=TRUE)]



# I MESSED THIS ONE UP!!








nypl[!is.na(isbn), .(barcode, numitems, isbn)]



nypl[,.N]
nypl[duplicated(barcode)]
nypl[barcode=="33433105673549", .(barcode, scsbid, numitems, title, oh09, localcallnum)]

cul[duplicated(barcode)]


cul[barcode=="CU61390550", .(barcode, scsbid, numitems, title, oh09, localcallnum)]








### number of scsbids under barcode

















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

