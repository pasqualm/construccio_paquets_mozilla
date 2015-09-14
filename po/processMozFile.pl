#!/usr/bin/env perl

use utf8;
use Encode;
use Encode::Detect::Detector;

binmode STDIN, ":utf-8";
binmode STDOUT, ":utf-8";
binmode STDERR, ":utf-8";

my $file = shift;
my $mode = shift;
my $code = shift;
my $value = shift;

my $encoding = Encode::Detect::Detector::detect($value);

$value = toutf8($encoding, $value);


my $strfile = "";

if ($mode eq 'dtd') {

open(FILE, $file ) || die "Cannot open $file";

while (<FILE>) {

	if ($_=~/^\<\!ENTITY\s*(\S+)\s*\"(.*)\"\s*\>/) {

			if ($1 eq $code) {
				$strfile.= "\<\!ENTITY $1\t\"$value\"\>\n";
			}
			else {
				$strfile.= $_;
			}
	}

	else {
		$strfile.= $_;
	}

}

close(FILE);

if ($strfile ne '') {

	open (FILEOUT, ">$file") || die "Cannot write!";
	print FILEOUT $strfile;
	close (FILEOUT);
}

}

elsif ($mode eq 'define') {

open(FILE, $file ) || die "Cannot open $file";

while (<FILE>) {

	if ($_=~/^\#define\s+(\S+)\s+(\S.*)\s*$/) {
			

			if ($1 eq $code) {
				$strfile.= "\#define $1 $value\n";
			}
			else {
				$strfile.= $_;
			}
	}

	else {
		$strfile.= $_;
	}

}

close(FILE);

if ($strfile ne '') {

        open (FILEOUT, ">$file") || die "Cannot write!";
        print FILEOUT $strfile;
        close (FILEOUT);

}


}


else {

open(FILE, $file ) || die "Cannot open $file";

while (<FILE>) {

	if ($_=~/^(\S+)\s*\=\s*(.*)\s*$/) {

			if ($1 eq $code) {
				$strfile.= "$1\=$value\n";
			}
			else {
				$strfile.= $_;
			}
	}

	else {
		$strfile.= $_;
	}

}

close(FILE);

if ($strfile ne '') {

        open (FILEOUT, ">$file") || die "Cannot write!";
        print FILEOUT $strfile;
        close (FILEOUT);

}


}

sub toutf8 {

#takes: $from_encoding, $text
#returns: $text in utf8
my $encoding = shift;
my $text = shift;

if ($encoding eq '') {
	$encoding = "utf-8";
}

if ($encoding =~ /utf\-?8/i) {
return $text;
}
else {
return Encode::encode("utf8", Encode::decode($encoding, $text));
}
}

