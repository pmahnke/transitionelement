#!/usr/local/bin/perl

my @file = `grep -lR -e .jpg -e .gif -e .png -e .pdf /Users/peter/Branches/transitionelement/_posts/*/*.textile`;

my (%wget) = '';

foreach my $file (@file) {

  open (FILE, $file) || die "Can't open $file";

  my (@lines, $output) = "";

  while (<FILE>) {

    print STDERR qq |looking at $_\n|;

    s/\.html" onclick="(.[^"]*)"/.jpg/g; # remove popup boxes

    if (/>/) {
      my @html = split(">");
      foreach (@html) {
        my $l = "$_>";
        print STDERR qq |multi $l\n|;
        push @lines, $l;
      }
      next;
    }

    push @lines, $_;

  }

  foreach (@lines) {

    #print STDERR qq |looking at $_\n|;

    if (/(src|href)/) {

      my ($img, $lastslash, $imgfilename) = "";

      my $orig_line = $_;

      # deal with popup images
#      if (/href/ && $_ !~ /onclick/) {
#        # not an image, just a link
#        $output .= $_;
#        next;
#      }

      # deal with code example
      if (/cid:/ || /\(\.\[\^/ || /\/assets\/images/) {
        $output .= $_;
        next;
      }

      if (/onclick/) {
        s/<a href="(.[^"]*)" onclick="(.[^>]*)>/<a href="$1">/g;
        s/html/jpg/g;
        print STDERR qq |found a popup on '$orig_line' and it is now '$_'\n|;
      }

      # find the image
      $img = "$2.$3" if (/(src|href)="(.[^\.]*)\.(.[^"]*)"/);

      # get just the file name
      $lastslash = rindex ($img, "\/");
      $imgfilename = substr($img, $lastslash+1);

      print STDERR qq |found image: $img with filename: $imgfilename in $_\n|;

      if ($img !~ /^http/) {

        # local, so add url

        # replace in file in the html
        s/$img/\/assets\/images\/$imgfilename/g;

        # make full page to wget
        $img = qq |http://www.transitionelement.com\/$img|;
        $wget{$img} = $imgfilename;

      } else {
        # not a local image, so get it then make it local
        $wget{$img} = $imgfilename;

        # replace in file in the html
        s/$img/\/assets\/images\/$imgfilename/g;

      }
      print STDERR qq |wget: $img from replaced html: $_\nwget --output-document=/Users/peter/Branches/transitionelement/assets/images/$imgfilename $img|;
    }
    $output .= $_;
  }
  close (FILE);

  open (OUT, ">$file") || die "Can't open $file";
  print OUT $output;
  close (OUT);

}

open (WGET, ">/Users/peter/Branches/transitionelement/wget.txt");
foreach (keys %wget) {
  if ($wget{$_} =~ /transitionelement.com/) {
    print `wget --output-document=/Users/peter/Branches/transitionelement/assets/images/$wget{$_} $_`;
  } else {
    print `wget --output-document=/Users/peter/Branches/transitionelement/assets/images/$wget{$_} $_`;
  }
  print WGET "$_\n";
}
close (WGET);
