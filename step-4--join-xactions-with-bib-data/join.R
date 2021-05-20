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
library(libbib)   # >= v1.6.2
library(assertr)

# ------------------------------ #



# 2.7 minutes
recap <- fread_plus_date("../target/RECAP.dat.gz")
expdate <- attr(recap, "lb.date")

recap %>% verify(nrow(.) >= 13193111, success_fun=success_report) # 2021-03-26


las <- fread("../target/transactions.dat")
las[, barcode:=toupper(barcode)]


setkey(las, "barcode")

recap[, barcode:=toupper(barcode)]
setkey(recap, "barcode")


recap[las, mult="first"] -> comb



setcolorder(comb, c("barcode", "item_owner", "order_owner", "req_date",
                    "ship_date", "inst_has_item"))

comb

set_lb_date(comb, expdate)
comb %>% fwrite_plus_date("../target/las-transaction-bib-info.dat")

