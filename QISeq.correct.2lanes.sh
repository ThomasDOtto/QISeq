#!/bin/bash

# Copyright (c) 2014-2016 Genome Research Ltd.
# Author: Thomas D. Otto <tdo@sanger.ac.uk>
#
# This file is part of QISeq.
#
# QISeq is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.
#
# Description: Corrects read using sga

read=$1
result=$2
tmp=$3

if [ -z "$tmp" ] ; then
	tmp="001";
fi

if [ -z "$BWA_THREADS" ]; then
  BWA_THREADS=1;
fi
export BWA_THREADS

# reads are prefiltered
sga preprocess  -m 51 --permute-ambiguous  -p 1  "$read"_1.fastq "$read"_2.fastq  > $read.$result.$tmp.fastq

# indexing via BWT
sga index -t $BWA_THREADS --disk=2000000  $read.$result.$tmp.fastq;

### evaluation of errors

sga correct -k 51 -x 3 -t $BWA_THREADS  -o $read.corrected.$result.$tmp.fastq $read.$result.$tmp.fastq;  

### transform the reads into _1 _2 and SE
QISeq.transformSGA_2files.pl  $read.corrected.$result.$tmp.fastq $read.CORR51_3
