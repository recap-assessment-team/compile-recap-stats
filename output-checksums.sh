#!/bin/bash

find ~/data/compile-recap-stats-data | parallel -j1 md5sum {} | perl -pe 'BEGIN{ $| = 1; } s/(\S+?)\s+.+?(compile-recap.+$)/\$HOME\/data\/$2\t$1/' | tee DATA-CHECKSUMS
