#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

my $dir = "/home/peter/src/personal/transitionelement/assets/images/insta";
my $outdir = "/home/peter/src/personal/transitionelement/assets/images/insta/smaller";

opendir(my $dh, $dir) or die "Can't open $dir: $!";
while (my $file = readdir($dh)) {
    next if $file =~ /^\./; # skip hidden files and . ..
    next unless $file =~ /\.(jpe?g)$/i;

    my $fullpath = "$dir/$file";
    my $newname = "$outdir/$file";

    # Resize
    system("/usr/bin/magick", $fullpath, "-resize", "2000x2000\\>", $newname) == 0
        or warn "Resize failed for $file";

    # Optimize
    system("/usr/bin/jpegoptim", "--strip-all", $newname) == 0
        or warn "jpegoptim failed for $file";
}
closedir($dh);
