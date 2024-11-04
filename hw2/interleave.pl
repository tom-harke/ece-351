use strict;
use warnings;

open HAVE, '<', 'pmodSSD_results.txt';
open WANT, '<', 'pmodSSD_tb_results.ref';

my ($h,$w);
O: while (1) {
  H: while (1) {
    $h = <HAVE>;
    exit unless defined $h;
    last H if $h =~ m/dig1/;
  }
  W: while (1) {
    $w = <WANT>;
    exit unless defined $w;
    last W if $w =~ m/dig1/;
  }
  $h =~ s/^#             /# /;
  $w =~ s/^#             /# /;
  $h =~ s/\t/  /g;
  $w =~ s/\t/  /g;
  if ($h eq $w) {
    print "same: $h";
  } else {
    print "\n";
    print "have: $h";
    print "want: $w";
    print "\n";
  }
}
