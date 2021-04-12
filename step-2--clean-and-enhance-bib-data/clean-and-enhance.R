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
library(libbib)   # version 1.0 (on CRAN)

source("../dependencies/utils.R")
# ------------------------------ #



PARSED_HTC_LOC <- "~/data/scsb-recap-exports/2021-03/parsed/"

nypl <- fread(sprintf("%s/NYPL-RECAP.dat", PARSED_HTC_LOC),
              colClasses="character", quote="", na.strings=c("", "NA", "NIL"))
# 2021-03:              6,263,710
nypl <- nypl[sharedp %chin% c("Shared", "Open"), ]
# OLD:                  4,838,430
# 2020-05-26:           4,848,922
# 2021-03:              4,938,534


cul <- fread(sprintf("%s/CUL-RECAP.dat", PARSED_HTC_LOC),
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"))
# 2021-03:              5,322,058
cul <- cul[sharedp %chin% c("Shared", "Open"), ]
# OLD:                  4,622,980
# 2020-05-26:           4,681,369
# 2021-03:              4,722,143


pul <- fread(sprintf("%s/PUL-RECAP.dat", PARSED_HTC_LOC),
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"))
# 2021-03:              3,971,988
pul <- pul[sharedp %chin% c("Shared", "Open"), ]
# OLD:                  3,367,792
# 2020-05-26:           3,191,778   (?)
# 2021-03:              3,532,434


OLDORDER <- names(nypl)



##################
##     LCCN     ##
##################
nypl[!is.na(lccn), lccn:=normalize_lccn(lccn)]
cul[!is.na(lccn), lccn:=normalize_lccn(lccn)]
pul[!is.na(lccn), lccn:=normalize_lccn(lccn)]





##################
##     ISBN     ##
##################
nypl[, tmp:=sprintf("nypl-%s-%s", barcode, scsbid)]
nypl[duplicated(tmp), .N]
# nypl <- nypl[!duplicated(tmp)]

cul[, tmp:=sprintf("cul-%s-%s", barcode, scsbid)]
cul[duplicated(tmp), .N]
# cul <- cul[!duplicated(tmp)]

pul[, tmp:=sprintf("pul-%s-%s", barcode, scsbid)]
pul[duplicated(tmp), .N]
# pul <- pul[!duplicated(tmp)]

nypl[!is.na(isbn), .(tmp, isbn)] -> one
cul[!is.na(isbn), .(tmp, isbn)] ->  two
pul[!is.na(isbn), .(tmp, isbn)] ->  three

comb <- rbindlist(list(one, two, three))

library(tidyr)
comb %>% separate_rows(isbn, sep=";") -> comb
comb <- as.data.table(comb)

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

comb %>% separate_rows(issn, sep=";") %>% as.data.table -> comb

comb[, fixedissn:=normalize_issn(issn)]


comb[, .(issn=paste(unique(fixedissn), collapse=";")), tmp] -> betterissns


# --------------------------------------------------------------- #


nypl[, inst_has_item:="NYPL"]
cul[, inst_has_item:="CUL"]
pul[, inst_has_item:="PUL"]

setcolorder(nypl, c("inst_has_item"))
setcolorder(cul, c("inst_has_item"))
setcolorder(pul, c("inst_has_item"))

recap <-rbindlist(list(nypl, cul, pul))

# old:~     12.8 million
# 2021-03:  13.2 million


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


betterrecap[, original_lccall:=lccall]
betterrecap[, lccall:=lccallp]

betterrecap[, lccallp:=NULL]

betterrecap %>% names

betterrecap[, tmp:=NULL]

neworder <- c("inst_has_item", "barcode", "vol", "numitems", "scsbid",
              "sharedp", "language", "pubdate", "biblevel", "recordtype",
              "oclc", "lccn", "isbn", "original_isbn", "issn",
              "original_issn", "lccall", "original_lccall", "localcallnum",
              "oh09", "pubplace", "pubsubplace", "leader", "oh08",
              "dateoflastxaction", "title", "author", "topicalterms")

setcolorder(betterrecap, neworder)

betterrecap %>% fwrite("./target/RECAP.dat",
                       sep="\t", na="NA")





