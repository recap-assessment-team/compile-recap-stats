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

# ------------------------------ #


LAS_XACTION_DATA_LOC <- "~/data/las-transactions/"


##
xwalk <- fread("./support/customer-code-xwalk.txt")
setkey(xwalk, thekey)

get_place <- function(x){
  places <- data.table(thekey=x)
  setindex(places, "thekey")
  results <- xwalk[places]
  return(results[,place])
}
##


list.files(LAS_XACTION_DATA_LOC) %>%
  sapply(function(x) sprintf("%s/%s", LAS_XACTION_DATA_LOC, x)) %>%
  lapply(function(x){ fread(x, colClasses="character", header=TRUE,
                            col.names=c("order_owner", "item_barcode",
                                        "item_owner", "req_date",
                                        "ship_date", "requestor", "stopp",
                                        "status", "order_type")) }) %>%
  rbindlist -> xactions

xactions[, ship_date:=as.Date(ship_date, format="%m/%d/%y")]
xactions[, req_date:=as.Date(req_date, format="%m/%d/%y")]

setorder(xactions, req_date)

# now join with xwalk
xactions[, made_order:=get_place(stopp)]
xactions[, item_owner:=get_place(item_owner)]


setcolorder(xactions, c("item_owner", "made_order", "item_barcode",
                        "req_date", "ship_date", "order_type"))
xactions

dt_keep_cols(xactions, c("item_owner", "made_order", "item_barcode",
                         "req_date", "ship_date"))

setnames(xactions, "made_order", "order_owner")
setnames(xactions, "item_barcode", "barcode")

setorder(xactions, "req_date", "barcode")

# no duplicates
xactions[,.N]
uniqueN(xactions)
xactions <- unique(xactions)
xactions[,.N]


xactions %>% fwrite("../target/transactions.dat")


