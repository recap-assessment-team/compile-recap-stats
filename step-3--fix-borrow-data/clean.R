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


library(lubridate)



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



fy19 <- fread("~/data/compile-recap-stats-data/las/LAS-FY19.csv",
              colClasses="character", header=TRUE,
              col.names=c("order_owner", "item_barcode", "item_owner",
                          "req_date", "ship_date", "requestor",
                          "stopp", "status", "order_type"))
fy20p <- fread("~/data/compile-recap-stats-data/las/LAS-FY20-part.csv",
               colClasses="character", header=TRUE,
               col.names=c("order_owner", "item_barcode", "item_owner",
                           "req_date", "ship_date", "requestor",
                           "stopp", "status", "order_type"))
fy18p <- fread("~/data/compile-recap-stats-data/las/LAS-BCE.csv",
               colClasses="character", header=TRUE,
               col.names=c("order_owner", "item_barcode", "item_owner",
                           "req_date", "ship_date", "requestor",
                           "stopp", "status", "order_type"))


fy18p
fy19
fy20p

xactions <- rbindlist(list(fy18p, fy19, fy20p))

xactions

xactions[, ship_date:=mdy(ship_date)]
xactions[, req_date:=mdy(req_date)]


# now join with xwalk
xactions[, made_order:=get_place(stopp)]
xactions[, item_owner:=get_place(item_owner)]


setcolorder(xactions, c("item_owner", "made_order", "item_barcode", "req_date", "ship_date", "order_type"))
xactions


keepcols(xactions, c("item_owner", "made_order", "item_barcode", "req_date",
                     "ship_date"))

setnames(xactions, "made_order", "order_owner")
setnames(xactions, "item_barcode", "barcode")

setorder(xactions, "req_date", "barcode")

# no duplicates
xactions[,.N]
xactions <- unique(xactions)
xactions[,.N]

# 2017-06-20 <-> 2019-09-20
# 550,350

xactions %>% fwrite("./target/transactions.dat", sep="\t", na="NA")


