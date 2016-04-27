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
# Description: Will get the two solexa files \1 and \2 and join them,
# replacing the name to .F and .R of each read name
#
####

use strict;


my $name1=shift;
my $resultName = shift;

if (!defined($resultName)) {
  die "Parameter: <root_s_x.mate.fastq> <Resultname>\n";
  
}


open (F1,$name1) or die "couldn't find file $name1: $!\n";

my $count=0;
my $res='';
my $resR='';
my $resSE='';

open (F, "> ".$resultName."_1.fastq" ) or die "probs";
open (R, "> ".$resultName."_2.fastq" ) or die "probs";
open (SE, "> ".$resultName."SE.fastq" ) or die "probs";

my $seqtmp;
my $qualtmp;

my $first;
my $resFirst='';
while (<F1>) {
  if (/\S+\..*w/) {
	print "ignore $_\n";
	<F1>;<F1>;<F1>;
  }
  else {
	
  ### change /1 to .F
  $count++;
  s/\.F$/\/1/g;
  s/\.R$/\/2/g;
	
## for capillary
s/\.p.*$/\/1/g;
s/\.q.*$/\/2/g;
	
  ### if forward
  if (/\/1/){
	#### if resFirst has entry, forward again
	 if ($resFirst ne ''){
	 	$resSE.=$resFirst;
	 }
  	$resFirst = $_;
  
    ($first)= $resFirst =~ /^.(.+)\/1/;
  	$count++;
#		print "$count \t $resFirst \t $first\n";
  
  	$resFirst.=<F1>;
  	$resFirst.=<F1>;
  	#qual
  	$resFirst.=<F1>;
   }
   ### if reverse
   elsif(/^.(.+)\/2/) {
	### is second, first must set
	my ($second) = $_ 	=~ /^.(.+)\/2/;
	if ($second eq $first){
		$res.=$resFirst;
		$resR .= $_;
 	    $resR.=<F1>;
  	    $resR.=<F1>;
  	    $resR.=<F1>;
		$resFirst='';
	}
	else {
		### it is reverse, but not machting mate pair;
		if ($resFirst ne ''){
	 	   $resSE.=$resFirst;
	 	   $resFirst='';
	 	}
	 	### it cannot have a mate anymore!
		$resSE .= $_;
 	    $resSE.=<F1>;
  	    $resSE.=<F1>;
  	    $resSE.=<F1>;
		}
   } # end if reverese
   else {
   	print "ignore cannot be error! $_ !!\n";
	<F1>;
<F1>;<F1>;   
die;
  }
  
}
  
  
  if (($count%200000)==0) {
	print F $res;
	$res='';
	print R $resR;
	$resR='';
	print SE $resSE;
	$resSE='';
  }
}

print F $res;
close(F);
print R $resR;
close(R);
print SE $resSE;
close(SE);
