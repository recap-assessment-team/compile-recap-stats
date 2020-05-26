#!/usr/local/bin/zsh

set -x
set -e

DATADIR="/media/tony/backups/data/compile-recap-stats-data"

./parse-all-marcxmls.lisp $DATADIR/htc/NYPL > $DATADIR/parsed-htc/NYPL-RECAP.dat
./parse-all-marcxmls.lisp $DATADIR/htc/CUL > $DATADIR/parsed-htc/CUL-RECAP.dat
./parse-all-marcxmls.lisp $DATADIR/htc/PUL > $DATADIR/parsed-htc/PUL-RECAP.dat
