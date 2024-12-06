#!/usr/bin/perl



my $dir = qq|/home/peter/src/personal/transitionelement/assets/images/|;

my $mvdir = qq|/home/peter/src/personal/insta|;

# read files in a directory
opendir(DIR, $dir) or die "Cannot open directory $dir: $!";

while (my $file = readdir DIR) {
    next if $file eq '.' or $file eq '..';  # Skip current and parent dirs
    next if ($file !~ /(.jpg|.webp)/i);
    push @img, $file;
}

my $i=1;
my $c=1;
foreach $file (@img) {

    my $count = `ag -c $file /home/peter/src/personal/transitionelement/_posts`;

    if (!$count) {
        print "$i BAD $file\n";
        #`mv $dir/$file $mvdir`;
        $count = "";
        $i++;
    } else {
        print "$c GOOD $file\n";
        $c++
    }

}

print "Done. $i unused images, $c good images\n";