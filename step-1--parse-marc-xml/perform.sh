#!/usr/local/bin/zsh

set -x
set -e

./parse-all-marcxmls.lisp ~/data/compile-recap-stats-data/htc/NYPL > ~/data/compile-recap-stats-data/parsed-htc/NYPL-RECAP.dat
./parse-all-marcxmls.lisp ~/data/compile-recap-stats-data/htc/CUL > ~/data/compile-recap-stats-data/parsed-htc/CUL-RECAP.dat
./parse-all-marcxmls.lisp ~/data/compile-recap-stats-data/htc/PUL > ~/data/compile-recap-stats-data/parsed-htc/PUL-RECAP.dat


