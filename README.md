# QISeq
A bioinformatical pipeline to process Quantitative Insertion-site Sequencing (QIseq) samples

Those script are part of the article: Quantitative Insertion-site Sequencing (QIseq): 
A new tool for high throughput phenotyping of transposon mutants XX XX XX

## Prequirements

Following tools are expected to installed in the path

   sga - to perform the correction of the reads <BR>
   bwa - to perform the mapping <BR>
   samtools - version 1.2 to work with cram files <BR>
   picard - to mark duplicates <BR>
   java - to start picard <BR>

IMPORTANT: We assume that the receipt of the illumina machine will know about adapter. Also, this adapter should be already trimmed in the bam files that will be given to the 

## Possible variables
Please ensure that all tools are in the path, and that markduplicates is in the CLASSPATH enviroment variable. <BR>
 <BR>
Variables to set <BR>
Some of the parameter can be be set through enviroment variables, like B=8; export B in bash <BR>
BWA_THREADS # amount of threads to be used for bwa mapping - default 1 <BR>
MIN_UNIQUE  # amount of unique reads to call an insertion site - default 4 <BR>

## Running
Assuming that the bam files is in the correct format, start the HISeq.start.sh for each direction (5'/3'), given the bam file, the direction, the reference and the offset bases to the adapter 4 for HiSeq and 5 for MiSeq.<BR>

F


