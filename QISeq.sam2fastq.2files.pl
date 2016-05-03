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
my $resultname=shift;
if ((!(defined($resultname)))) {
  die "Please defined resultname\n";
  
}
open F, ">".$resultname."_1.fastq" or die "problesm";
open R, ">".$resultname."_2.fastq" or die "problesm";

# get's the input from a awk command.


my %seenMate;

my @ar;
my $res1='';
my $res2='';

my $count=0;

my %QISeqOK;
while (<STDIN>) {
  chomp;
  
  @ar =split(/\t/);
 $ar[0] =~ s/\.R$//g;
 $ar[0] =~ s/\.F$//g;
  $ar[0] =~ s/\/\d$//g;

my $QISeqQual="";
my $QISeq="";
if (/tr:Z:(\S+)/){
	$QISeq=$1;
$QISeqOK{$ar[0]}=1;
/tq:Z:(\S+)/;
$QISeqQual=$1;
}  

  if (defined($seenMate{$ar[0]})) {
	### first mate
	my $tmp=getfastq(\@ar,$QISeq,$QISeqQual);
	
	if ($ar[1] & 0x0040 && defined($QISeqOK{$ar[0]})) {
	  $res1.=$tmp;
	  $res2.=$seenMate{$ar[0]}
	}
	elsif (defined($QISeqOK{$ar[0]})) {
	  $res1.=$seenMate{$ar[0]};
	  $res2.=$tmp;
	}
	delete($seenMate{$ar[0]});
	
	$count++;
	if (($count%100000)==0) {
	
	  print F $res1;
	  $res1='';
	  print R $res2;
	  $res2='';
	  
	}
	
  }
  else {
	$seenMate{$ar[0]}=getfastq(\@ar,$QISeq,$QISeqQual)
  }
}
print F $res1;
print R $res2;
close(F);
close(R);

#print $res;
exit 0;
open F, ">".$resultname."SE.fastq" or die "problesm";
foreach my $r (keys %seenMate) {
  print F "$seenMate{$r}";
}
close(F);


sub revcomp{
  my $str = (shift);
  $str =~ tr/ATGCatgc/TACGtacg/;
  
  return reverse($str);
}

sub getfastq{
  my $ar=shift;
	
#### insertion of QISeq
my $QISeq=shift;  
my $QISeqQual=shift;

  my $res;
  if ($$ar[1] & 0x0040) {
	$res="@".$$ar[0]."/1\n";
  }
  else {
	$res="@".$$ar[0]."/2\n";
  }
if (defined($QISeq)){
  if ($$ar[1] & 0x0010) {
	### have to recomp seq
	$res.=$QISeq.revcomp($$ar[9])."\n"."+\n".$QISeqQual.reverse($$ar[10])."\n";
  }
  else {
	$res.=$QISeq.$$ar[9]."\n"."+\n$QISeqQual".$$ar[10]."\n";
  }}
else {
if ($$ar[1] & 0x0010) {
        ### have to recomp seq
        $res.=revcomp($$ar[9])."\n"."+\n".reverse($$ar[10])."\n";
  }
  else {
        $res.=$$ar[9]."\n"."+\n".$$ar[10]."\n";
  }
}
  return $res
}
