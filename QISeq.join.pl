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
# Description: join the samples in the end, 3' and 5'

use strict;

my $index=shift;
my $names=shift;
my $dir  = shift;
my $ref_n=getNames($names);
my $res;
if (!defined($$ref_n{$index})){
$res=$index."\t$dir";
} else {
$res=$$ref_n{$index}."\t$dir";
}
my $res2;
my $amount=-1;;
while(<>){
		chomp;
		$amount++;
		$res2.="\t".$_;
}

print $res."\t$amount"."$res2\n";

sub getNames{
	my $n=shift;
	open F, $n or die "problem\n";
	
	my %h;
	while(<F>){
		chomp;
		my @ar=split(/\t/);
		$h{$ar[2]}=$ar[0];
	}	
	close(F);
	return \%h
}
