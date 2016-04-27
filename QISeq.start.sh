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
# this program. If not, see <http://www.gnu.org/licenses/>.#### QISeq.start.sh
#
# QISeq.start.sh is the program to start the QISeq pipeline for one sample and one direction
####

### unique id of the sequencing run / barcode 
id=$1
### if 3' or 5' 
sense=$2
### specify the reference for the mapping
ref=$3
### the offset is 5 for MiSeq and 4 for Hiseq
offset=$4

#path="/nfs/pathogen003/tdo/Tools/Tradis"; 

if [ -z "$offset" ] ; then
    warn "offset is set to 5 (Miseq Option)!"
    offset=5;
fi

if [ ! -f $id.bam ]; then
    echo "bam file not found!" 
	if [ ! -f $id.cram ]; then
		echo "cram file not found!"
		exit -1;
	fi
fi

if [ -z "$ref" ] ; then 
    echo "Please define a reference for the mapping!"
    exit -1;
fi

### mininmal unique insertion sites; this can be lowered if needed
if [ -z "$MIN_UNIQUE" ]; then
MIN_UNIQUE=4; export MIN_UNIQUE
fi

### get the fastq reads, include read1 the QISeq.tag
if [ -f  $id.cram ]; then
	samtools1.2 view -F 2048  $id.cram | QISeq.sam2fastq.2files.pl $id
else 
	samtools view $id.bam     | QISeq.sam2fastq.2files.pl $id
fi

### correct the reads with SGA
QISeq.correct.2lanes.sh $id 52 001

### delete again the adapter from reads1
cat $id.CORR51_3_1.fastq | perl -e 'while (<>){ print; $_=<STDIN>; print substr($_,12);$_=<STDIN>;print; $_=<STDIN>; print substr($_,12); }' > $id.OK.CORR51_3_1.fastq

#### map the reads: this will mapping limits the 
QISeq.map.sh $ref 17 3 $id.OK.CORR51_3_1.fastq $id.CORR51_3_2.fastq MAP.$id 1000 
bam=MAP.$id/out.sorted.markdup.bam

#### Get amount of insertion sites, uniq -F 1024 excludes duplicates 
samtools view -f 66 -F 1024 $bam | QISeq.determineStartsite.pl $offset | sort | uniq -c |sort -rn | QISeq.fixbases.pl $MIN_UNIQUE > Correct.$id.$sense.txt

#### Get amount of insertion sites 
samtools view -f 66 $bam | QISeq.determineStartsite.pl $offset |  sort | uniq -c |sort -rn | QISeq.fixbases_normalized_correctDup.pl  Correct.$id.$sense.txt  > Res.$id.$sense.txt

