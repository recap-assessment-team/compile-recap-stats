#!/usr/local/bin/zsh

set -x
set -e

DATADIR=$(find /home/tony/data/scsb-recap-exports/ -maxdepth 1 | sort | tail -n 1)
EXPDATE=$(echo $DATADIR | perl -pe 's/^.+(\d{4}-\d{2}-\d{2})/$1/')
echo $DATADIR
echo $EXPDATE

time ./parse-all-marcxmls.lisp $DATADIR/NYPL > ./target/NYPL-RECAP-$EXPDATE.dat
time ./parse-all-marcxmls.lisp $DATADIR/CUL  > ./target/CUL-RECAP-$EXPDATE.dat
time ./parse-all-marcxmls.lisp $DATADIR/PUL  > ./target/PUL-RECAP-$EXPDATE.dat


### 2021-03 timings
    # NYPL 1.6 hours
    # User-mode: 5222.93s     Kernel-mode: 435.70s    Wall: 5672.91s  Perc: 99%
    # CUL 1.7 hours
    # User-mode: 5718.61s     Kernel-mode: 483.55s    Wall: 6208.84s  Perc: 99%
    # PUL 1.2 hours
    # User-mode: 4129.41s     Kernel-mode: 354.93s    Wall: 4487.91s  Perc: 99%


