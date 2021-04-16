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
library(libbib)   # version 1.3.3

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




nypl[, inst_has_item:="NYPL"]
cul[, inst_has_item:="CUL"]
pul[, inst_has_item:="PUL"]

setcolorder(nypl, c("inst_has_item"))
setcolorder(cul, c("inst_has_item"))
setcolorder(pul, c("inst_has_item"))

recap <-rbindlist(list(nypl, cul, pul))

recap[,.N]
# old:~     12.8 million
# 2021-03:  13.2 million

rm(nypl)
rm(cul)
rm(pul)
gc()





##########
####  LCCN
recap[!is.na(lccn), lccn:=normalize_lccn(lccn)]         # 1.2 minutes



##########
####  ISBN
recap[, original_isbn:=isbn]
recap[!is.na(original_isbn),
      isbn:=split_map_filter_reduce(original_isbn,
                                    mapfun=function(x){normalize_isbn(x, convert.to.isbn.13=TRUE)},
                                    filterfun=remove_duplicates_and_nas,
                                    reduxfun=recombine_with_sep_closure(),
                                    cl=9)]
# 6.5 minutes / 17 minutes




##########
####  ISSN
recap[, original_issn:=issn]
recap[!is.na(original_issn),
      issn:=split_map_filter_reduce(original_issn,
                                    mapfun=function(x){normalize_issn(x)},
                                    filterfun=remove_duplicates_and_nas,
                                    reduxfun=recombine_with_sep_closure(),
                                    cl=7)]
# 18 minutes / 2.5 minutes




##############
####  LC CALLS
recap[, original_lccall:=lccall]
recap[inst_has_item!="NYPL" & !is.na(localcallnum) & is.na(lccall)
      & (!str_detect(localcallnum, ":") | str_detect(localcallnum, "\\s+\\.[A-Z]\\d")) # 12th
      & !str_detect(localcallnum, "^(F|M)\\s+\\d+$")
      & is_valid_lc_call(localcallnum), lccall:=localcallnum]

recap[!is.na(lccall),
      subject_classification:=get_lc_call_subject_classification(lccall)]

recap[is.na(subject_classification), lccall:=NA]

recap[!is.na(lccall),
      subject_subclassification:=get_lc_call_subject_classification(lccall,
                                                                    subclassification=TRUE)]






neworder <- c("inst_has_item", "barcode", "vol", "numitems", "scsbid",
              "sharedp", "language", "pubdate", "biblevel", "recordtype",
              "oclc", "lccn", "original_isbn", "isbn", "original_issn",
              "issn", "original_lccall", "lccall", "localcallnum", "oh09",
              "pubplace", "pubsubplace", "leader", "oh08",
              "dateoflastxaction", "title", "author", "topicalterms",
              "subject_classification", "subject_subclassification")


setcolorder(recap, neworder)

recap %>% fwrite("../target/RECAP.dat.gz",
                 sep="\t", na="NA")
# 19 seconds
# 1 GB (down from 5GB uncompressed

