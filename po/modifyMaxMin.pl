#!/usr/bin/env perl

use warnings;
use strict;

my $zipfile = shift;

use Archive::Zip;
use Archive::Zip::MemberRead;
my $zip = Archive::Zip->new($zipfile);
my $fh  = Archive::Zip::MemberRead->new($zip, "install.rdf");

my $file = "install.rdf";
  
open FH, '>', $file or die $!;
  
  while (defined(my $line = $fh->getline()))
  {
      chomp $line;
      if ($line =~ /minVersion\>(.*)\</) {
	my $num = quotemeta($1);
	my $nume = convertn($num);
	$nume = $nume.".0";
        $line =~ s/$num/$nume/;
        print FH "$line\n";
      } elsif ($line =~ /maxVersion\>(.*)\</) {
	my $num = quotemeta($1);
        my $nume = convertn($num);
        $nume = $nume.".*";
        $line =~ s/$num/$nume/;
        print FH "$line\n";
	} elsif ($line=~/^\s*$/) {
	next;
        }else {
        print FH "$line\n";
      }        
  }

close FH or die "error writing $file: $!\n";

$zip->updateMember("install.rdf", $file) or die "updateMember";

$zip->overwriteAs($zipfile);

sub convertn {

	my $num = shift;
	my ($digit) = $num=~/^(\d+)/;

	return($digit);
}
