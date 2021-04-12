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

source("../dependencies/utils.R")

# ------------------------------ #


recap <- fread("../step-2--clean-and-enhance-bib-data/target/RECAP.dat")


las <- fread("../step-3--fix-borrow-data/target/transactions.dat")
las[, barcode:=toupper(barcode)]

# las <- las[item_owner %chin% c("CUL", "NYPL", "PUL")]

setkey(las, "barcode")


recap[,.N]
# 12,829,196

recap[, barcode:=toupper(barcode)]
setkey(recap, "barcode")


# recap[las] -> comb
# recap[las, mult="first", nomatch=0L] -> comb
recap[las, mult="first"] -> comb

recap[,.N]
las[,.N]
comb[,.N]


comb[, .N, !is.na(inst_has_item)]
## 2021-03
   #  is.na      N
   # <lgcl>  <int>
   # 1:   TRUE 578798
   # 2:  FALSE 177401
# 77%


comb[is.na(inst_has_item)]
comb[!is.na(inst_has_item)]
comb[is.na(inst_has_item), .N]


OLDORDER <- names(comb)

setcolorder(comb, c("barcode", "item_owner", "order_owner", "req_date",
                    "ship_date", "inst_has_item"))

comb

comb %>% fwrite("./target/las-transaction-bib-info.dat", sep="\t", na="NA")



