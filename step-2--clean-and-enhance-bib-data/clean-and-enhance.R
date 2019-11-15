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
library(tidyr)


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



OLDORDER <- names(nypl)



##################
##     LCCN     ##
##################
nypl[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2019)]
cul[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2019)]
pul[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2019)]





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
##     ISSN     ##
##################
nypl[!is.na(issn), .(tmp, issn)] -> one
cul[!is.na(issn), .(tmp, issn)] ->  two
pul[!is.na(issn), .(tmp, issn)] ->  three

comb <- rbindlist(list(one, two, three))

comb %>% separate_rows(issn, sep=";") -> comb

comb[, fixedissn:=normalize_issn(issn, pretty=TRUE)]

# uniqueN(comb[, .(isbn)])
# uniqueN(comb[, .(fixedisbn)])
#
# comb[1:10][, .(isbn=paste(unique(isbn), collapse=";")), tmp]
# comb[1:10][, .(isbn=paste(unique(fixedisbn), collapse=";")), tmp]
# comb[1:10][, .(isbn=paste(unique(fixedisbn), collapse=";")), tmp]

comb[, .(issn=paste(unique(fixedissn), collapse=";")), tmp] -> betterissns


# --------------------------------------------------------------- #


nypl[, inst_has_item:="NYPL"]
cul[, inst_has_item:="CUL"]
pul[, inst_has_item:="PUL"]

setcolorder(nypl, c("inst_has_item"))
setcolorder(cul, c("inst_has_item"))
setcolorder(pul, c("inst_has_item"))

recap <-rbindlist(list(nypl, cul, pul))

# 12.8 million


# LC CALLS

recap %>% names
recap[, lccallp:=lccall]
recap[inst_has_item!="NYPL" &
      !is.na(localcallnum) &
      is.na(lccall) &
      str_detect(localcallnum,
                 "^[A-Z][A-Z]?\\d+")
    , lccallp:=localcallnum]




recap[1:3,]



## join fixed controls
setnames(recap, "isbn", "original_isbn")
setnames(recap, "issn", "original_issn")

recap

setkey(recap, "tmp")
setkey(betterisbns, "tmp")
setkey(betterissns, "tmp")

recap[, .N]
betterisbns[recap] -> betterrecap

betterissns[betterrecap] -> betterrecap


betterrecap[1:3]

OLDORDER <- c("inst_has_item", OLDORDER)

setcolorder(betterrecap, OLDORDER)

betterrecap[, original_lccall:=lccall]
betterrecap[, lccall:=lccallp]

betterrecap[, lccallp:=NULL]

betterrecap %>% names









