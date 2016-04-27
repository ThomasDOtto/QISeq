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
# Description: script to align with maq a read pair Illumina/Solexa lane onto a genome to produce a bam file for Artemis.
# samtools and bwa must be in the PATH
#
####

set -e

genome=$1
kmer=$2
stepsize=$3
fastqF=$4
fastqR=$5
resultname=$6
insertSize=$7

#randome stamp for temporary file name
tmp=$$
if [ -z "$insertSize" ] ;
		then
		echo "Usage: <genome> <k-mer> <stepsize> <Illumina forward reads> <Illumina reverse reads; 0 if single Reads> <resultname> <Insertsize Range:i.e. 350, 0 if single> optional: for more specific parameter, set the SMALT_PARAMETER enrovimental variable"
		echo
		exit;
	fi;

if [ -z "$BWA_THREADS" ]; then
  BWA_THREADS=1;
fi

export BWA_THREADS

	echo "Start bwa mapping";
		if [ ! -f "$genome.rpac" ] ; then
		#Creating the index for bwa of the genome if it does not exist
		bwa index $genome
		echo "skipped that..."
		fi;
		
		tmp=$$
		
		#Mapping the reads against the genome
		bwa aln -t $BWA_THREADS $BWA_aln $genome $fastqF > $tmp.F.sai;
		bwa aln -t $BWA_THREADS $BWA_aln $genome $fastqR > $tmp.R.sai;
		
		#Join both aligments
		bwa sampe -a $insertSize $genome  $tmp.F.sai $tmp.R.sai  $fastqF  $fastqR > $resultname.$tmp.sam;
	touch out.$tmp.txt

# Convert reference to fai for bam file
samtools faidx $genome

# SAM to BAM
read=$(echo $fastqF | sed 's/_1.fastq//g');
echo -e "@RG\tID:$read\tSM:1" > line.$tmp.txt
awk -va=$read '{if ($1~/^@/) {print} else  {print $0"\tRG:Z:"a}}'  $resultname.$tmp.sam | samtools view -b -t $genome.fai - > $resultname.$tmp.bam
rm $resultname.$tmp.sam

samtools view -H  $resultname.$tmp.bam > header.$tmp.txt
echo -e "@RG\tID:$read\tSM:1" >>  header.$tmp.txt
samtools reheader header.$tmp.txt  $resultname.$tmp.bam  > $resultname.$tmp.2.bam
rm $resultname.$tmp.bam

# <(cat line.$tmp.txt $resultname.$tmp.sam)
mkdir $resultname
#samtools import $genome.fai $resultname.$tmp.sam $resultname.$tmp.bam
#samtools view -S -b -h $resultname.$tmp.sam > $resultname.test.$tmp.bam
#order the bam file
samtools sort $resultname.$tmp.2.bam $resultname/out
rm  $resultname.$tmp.2.bam
java -XX:MaxPermSize=512m -Xmx4000m -XX:ParallelGCThreads=1 -XX:-UseParallelGC -XX:+UseSerialGC -jar MarkDuplicates.jar VALIDATION_STRINGENCY=SILENT M=/dev/null ASSUME_SORTED=TRUE MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 I=$resultname/out.bam O=$resultname/out.sorted.markdup.bam 
return=$?
if [ "$return" != "0" ] ;
	then 
	echo "Sorry, mark duplicates failed again..."
	echo "please check if MarkDuplicates.jar is set in the classpath and java is up to date."
	echo "java -XX:MaxPermSize=512m -Xmx4000m -XX:ParallelGCThreads=1 -XX:-UseParallelGC -XX:+UseSerialGC -jar MarkDuplicates.jar VALIDATION_STRINGENCY=SILENT M=/dev/null ASSUME_SORTED=TRUE MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 I=$resultname/out.bam O=$resultname/out.sorted.markdup.bam"
	exit 1;
fi;
#index the bam file, to get the bai file.
rm $resultname/out.bam

samtools index  $resultname/out.sorted.markdup.bam

###delete files
rm  line.$tmp.txt out.$tmp.txt  header.$tmp.txt
 

