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


source("~/.rix/tony-utils.R")
# ------------------------------ #

source("bibcodes.R")

# PARSED_HTC_LOC <- "~/data/compile-recap-stats-data/parsed-htc/"
PARSED_HTC_LOC <- "~/Desktop/parsed-htc/"

# OLD:                  4,838,430    2,453,742
# 2020-05-26:           4,848,922
nypl <- fread(sprintf("%s/NYPL-RECAP.dat", PARSED_HTC_LOC),
              colClasses="character", quote="", na.strings=c("", "NA", "NIL"))


# OLD:                  4,622,980   3,296,623
# 2020-05-26:           4,681,369
cul <- fread(sprintf("%s/CUL-RECAP.dat", PARSED_HTC_LOC),
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"),
             fill=TRUE)

# OLD:                  3,367,792    2,200,337
# 2020-05-26:           3,191,778
pul <- fread(sprintf("%s/PUL-RECAP.dat", PARSED_HTC_LOC),
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"))



OLDORDER <- names(nypl)



##################
##     LCCN     ##
##################
nypl[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2020)]
cul[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2020)]
pul[!is.na(lccn), lccn:=normalize_lccn(lccn, year.cutoff=2020)]





##################
##     ISBN     ##
##################
nypl[, tmp:=sprintf("nypl-%s-%s", barcode, scsbid)]
nypl[duplicated(tmp), .N]
# OLD:          only one
# 2020-05-26:   only one
nypl <- nypl[!duplicated(tmp)]

cul[, tmp:=sprintf("cul-%s-%s", barcode, scsbid)]
# OLD:          only five
# 2020-05-26:   only five
cul[duplicated(tmp), .N]
cul <- cul[!duplicated(tmp)]

pul[, tmp:=sprintf("pul-%s-%s", barcode, scsbid)]
# OLD:          none
# 2020-05-26:   none
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

comb[, fixedissn:=normalize_issn(issn, pretty=TRUE)]


comb[, .(issn=paste(unique(fixedissn), collapse=";")), tmp] -> betterissns


# --------------------------------------------------------------- #


nypl[, inst_has_item:="NYPL"]
cul[, inst_has_item:="CUL"]
pul[, inst_has_item:="PUL"]

setcolorder(nypl, c("inst_has_item"))
setcolorder(cul, c("inst_has_item"))
setcolorder(pul, c("inst_has_item"))

recap <-rbindlist(list(nypl, cul, pul))

# ~ 12.8 million


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



betterrecap %>% fwrite("./target/RECAP.dat",
                       sep="\t", na="NA")





