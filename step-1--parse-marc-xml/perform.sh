#!/usr/local/bin/zsh

set -x
set -e

DATADIR="/home/tony/data/scsb-recap-exports/2021-03/"

time ./parse-all-marcxmls.lisp $DATADIR/unparsed/NYPL > $DATADIR/parsed/NYPL-RECAP.dat
time ./parse-all-marcxmls.lisp $DATADIR/unparsed/CUL > $DATADIR/parsed/CUL-RECAP.dat
time ./parse-all-marcxmls.lisp $DATADIR/unparsed/PUL > $DATADIR/parsed/PUL-RECAP.dat


### 2021-03 timings
    # NYPL 1.6 hours
    # User-mode: 5222.93s     Kernel-mode: 435.70s    Wall: 5672.91s  Perc: 99%
    # CUL 1.7 hours
    # User-mode: 5718.61s     Kernel-mode: 483.55s    Wall: 6208.84s  Perc: 99%
    # PUL 1.2 hours
    # User-mode: 4129.41s     Kernel-mode: 354.93s    Wall: 4487.91s  Perc: 99%


