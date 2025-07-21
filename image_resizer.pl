#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;


print "what directory?\n";
my $input = <STDIN>;
chop($input);
if (!$input) {
    print "Nothing to do\n";
    exit;
} 

my $dir = "/home/peter/src/personal/transitionelement/assets/images/$input";
if ( ! -d $dir ) {
    print "Directory does not exist: $dir\n";
    exit;
} else {
    print "looking at |$dir|\n";
#    exit;
}

my $outdir = "/home/peter/src/personal/transitionelement/assets/images/smaller";

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
