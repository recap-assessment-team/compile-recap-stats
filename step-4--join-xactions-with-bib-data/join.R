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

# ------------------------------ #


# 2.7 minutes
recap <- fread("../target/RECAP.dat.gz")

las <- fread("../target/transactions.dat")
las[, barcode:=toupper(barcode)]

setkey(las, "barcode")


recap[,.N]
# 2021-03: 13,193,111

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


setcolorder(comb, c("barcode", "item_owner", "order_owner", "req_date",
                    "ship_date", "inst_has_item"))

comb

comb %>% fwrite("../target/las-transaction-bib-info.dat", sep="\t", na="NA")



