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
# Description: calculate the start site. If forward read map positive strand, start hit plus 4 / 5, reverse, need to look into the cigar string
# further expect no softclipping after the insert!

use strict;

my $offset=shift;
while (<>){
	chomp; 
	my @ar=split(/\t/); 
	
	if ($ar[1] & 0x010) {  
		if ( $ar[5] =~ /^\d+M/){
			my $lgth=getLength($ar[5]);
			print $ar[2]."\t".($ar[3]+$lgth+$offset)."\t$lgth\t$ar[5]\n";
			}    
		}
		elsif($ar[5] =~ /^\d+M/) {  
			print $ar[2]."\t".($ar[3]-$offset)."\t0\n";  
		}
} 

sub getLength{
	my $cigar=shift;	
	$cigar=~ s/^\d+S//g;
	my $lgth=0;
	while ($cigar){
		if ($cigar=~/^(\d+)M/){
		 $lgth+=$1; 
		 $cigar=~s/^(\d+)M//g;	
		}	 
		if($cigar=~/^(\d+)I/){
		 $lgth-=$1; 
		 $cigar=~s/^(\d+)I//g;	
		}	
		if($cigar=~/^(\d+)D/){
		 $lgth+=$1; 
		 $cigar=~s/^(\d+)D//g;	
		}	
		if($cigar=~/^(\d+)S/){
		 $lgth+=$1; 
		 $cigar=~s/^(\d+)S//g;	
		} 
	}
	return $lgth;
}
