#! /usr/bin/perl -w
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
# Description: 
use strict;


my %h;
my %around;

my $filteredInsert=shift;
#my $correction=shift;
#my $minAmount=shift;

if (!defined($filteredInsert)){
die "gimme the files with ok sites... call me through the pipeline mate!\n";
}

my $ref_oksite=getSites($filteredInsert);


my @readin;
my $mapped=0;
while (<>) {
  chomp;
  push @readin, $_;
}

my @order;
### input some thing like 
# cat Insert.$i.frd.txt | cut -f 1,2,3|  sort | uniq -c |sort -rn 
foreach (@readin) {

    s/^\s+//g;
	my ($amount, $chr, $pos)=split(/\s+/);
	my $posAround=int ($pos/1000);
	### get the insertion site correct
	if (defined($around{$chr}{$posAround})){
		my $posnew=findPos($pos,$chr,\%h);
		$h{$chr}{$posnew}+=$amount;
		if (defined($$ref_oksite{$chr}{$posnew})){
		  $mapped+=$amount;
		}
	}
	else {
		$h{$chr}{$pos}=$amount;
		$around{$chr}{$posAround}=1;
		push @order, $chr."::".$pos;
		if (defined($$ref_oksite{$chr}{$pos})){
		  $mapped+=$amount;
		}
	}
	
}
foreach my $i (@order){
  my ($chr,$pos)=split(/::/,$i);
		if (defined($$ref_oksite{$chr}{$pos})){
		  my $norm=(sprintf("%.2f",($h{$chr}{$pos}/$mapped*100000)));
		  print "$norm\t$h{$chr}{$pos}\t$chr\t".($pos)."\n";
		}	
}
	
sub findPos{
	my $pos=shift;
	my $chr=shift;
	my $ref=shift;	
	my $found =0;
	my $posN=0;
	for my $i (1..10) {
		if (!$found && defined($$ref{$chr}{$pos+$i})){
			$found=1;
			$posN=($pos+$i)
		}
		elsif(!$found && defined($$ref{$chr}{$pos-$i})){
			$found=1;
			$posN=($pos-$i)
		}
	}

	if ($found) {
		return $posN;
	}
	else {
		return $pos;
	}
}


sub getSites{
  my $f = shift;

  open F, $f or die "problem openen file $f: \n";
  my %ok;
  while (<F>) {
	chomp;
	s/^\s+//g;
	my ($amount, $chr, $pos)=split(/\s+/);
	for (-30..30){
	$ok{$chr}{($pos+$_)}=$amount;
}
  }
  return \%ok;
  
}
