#!/usr/local/bin//Rscript --vanilla


# ------------------------------ #
rm(list=ls())

options(echo=TRUE)
options(width=80)
options(warn=2)
options(scipen=10)
options(datatable.prettyprint.char=50)
options(datatable.print.class=TRUE)
options(datatable.print.keys=TRUE)
options(datatable.fwrite.sep='\t')
options(datatable.na.strings="")

args <- commandArgs(trailingOnly=TRUE)

library(colorout)
library(data.table)
library(magrittr)
library(stringr)
library(libbib)   # >= v1.6.2
library(assertr)

# ------------------------------ #


nypl <- fread_plus_date("../step-1--parse-marc-xml/target/NYPL-RECAP.dat",
              colClasses="character", quote="", na.strings=c("", "NA", "NIL"),
              strip.white=FALSE)
nypl %>% verify(nrow(.) >= 6263710, success_fun=success_report) # 2021-03-26

nypl <- nypl[sharedp %chin% c("Shared", "Open"), ]
# nypl %>% verify(nrow(.) >= 4848922, success_fun=success_report) # 2021-05-26
nypl %>% verify(nrow(.) >= 4938534, success_fun=success_report) # 2021-03-26



cul <- fread_plus_date("../step-1--parse-marc-xml/target/CUL-RECAP.dat",
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"),
             strip.white=FALSE)
cul %>% verify(nrow(.) >= 5322058, success_fun=success_report) # 2021-03-26

cul <- cul[sharedp %chin% c("Shared", "Open"), ]
# cul %>% verify(nrow(.) >= 4681369, success_fun=success_report) # 2021-05-26
cul %>% verify(nrow(.) >= 4722143, success_fun=success_report) # 2021-03-26



pul <- fread_plus_date("../step-1--parse-marc-xml/target/PUL-RECAP.dat",
             colClasses="character", quote="", na.strings=c("", "NA", "NIL"),
             strip.white=FALSE)
pul %>% verify(nrow(.) >= 3971988, success_fun=success_report) # 2021-03-26

pul <- pul[sharedp %chin% c("Shared", "Open"), ]
# pul %>% verify(nrow(.) >= 3191778, success_fun=success_report) # 2020-05-26 (?)
pul %>% verify(nrow(.) >= 3532434, success_fun=success_report) # 2021-03-26


expdate <- attr(nypl, "lb.date")


nypl[, inst_has_item:="NYPL"]
cul[, inst_has_item:="CUL"]
pul[, inst_has_item:="PUL"]

setcolorder(nypl, c("inst_has_item"))
setcolorder(cul, c("inst_has_item"))
setcolorder(pul, c("inst_has_item"))

recap <-rbindlist(list(nypl, cul, pul))

recap[,.N]
# old:~         12.8 million
# 2021-03-26:   13.2 million

rm(nypl)
rm(cul)
rm(pul)
gc()


recap[, language:=get_language_from_code(lang_code)]
recap[, pubplace:=get_country_from_code(pubplace_code)]



###############
###############
####  LCCN
###############
recap[!is.na(lccn), lccn:=normalize_lccn(lccn)]         # 1.2 minutes



###############
###############
####  ISBN
###############
recap[, original_isbn:=isbn]
recap[!is.na(original_isbn),
      isbn:=split_map_filter_reduce(original_isbn,
                                    mapfun=function(x){normalize_isbn(x, convert.to.isbn.13=TRUE)},
                                    filterfun=remove_duplicates_and_nas,
                                    reduxfun=recombine_with_sep_closure(),
                                    cl=7)]
# 6.5 minutes or 17 minutes




###############
###############
####  ISSN
###############
recap[, original_issn:=issn]
recap[!is.na(original_issn),
      issn:=split_map_filter_reduce(original_issn,
                                    mapfun=function(x){normalize_issn(x)},
                                    filterfun=remove_duplicates_and_nas,
                                    reduxfun=recombine_with_sep_closure(),
                                    cl=7)]
# 2.5 minutes or 18 minutes




#################
#################
####  LC CALLS
#################
recap[, original_lccall:=lccall]
recap[inst_has_item!="NYPL" & !is.na(localcallnum) & is.na(lccall)
      & (!str_detect(localcallnum, ":") | str_detect(localcallnum, "\\s+\\.[A-Z]\\d")) # 12th
      & !str_detect(localcallnum, "^(F|M)\\s+\\d+$")
      & is_valid_lc_call(localcallnum), lccall:=localcallnum]

recap[!is.na(lccall),
      subject_classification:=get_lc_call_subject_classification(lccall)]
# 1.7 minutes

recap[is.na(subject_classification), lccall:=NA]

recap[!is.na(lccall),
      subject_subclassification:=get_lc_call_subject_classification(lccall,
                                                                    subclassification=TRUE)]
# 1.7 minutes




################################
################################
####  DATES AND OTHER THINGS
################################
recap %>% names
recap[, dateoflastxaction:=as.Date(dateoflastxaction)]
recap[, pubdate:=as.integer(pubdate)]
recap[year(Sys.Date()) < pubdate, pubdate:=NA]
recap[pubdate < 1500, pubdate:=NA]



neworder <- c("inst_has_item", "barcode", "vol", "numitems", "scsbid",
              "sharedp", "lang_code", "language", "pubdate", "biblevel",
              "recordtype", "oclc", "lccn", "original_isbn", "isbn",
              "original_issn", "issn", "original_lccall", "lccall",
              "localcallnum", "oh09", "pubplace_code", "pubplace",
              "pubsubplace", "leader", "oh08", "dateoflastxaction",
              "title", "author", "topicalterms", "subject_classification",
              "subject_subclassification")

setcolorder(recap, neworder)

set_lb_date(recap, expdate)
recap %>% fwrite_plus_date("../target/RECAP.dat.gz")

