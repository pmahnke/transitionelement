#!/usr/bin/perl

################################################################################
#
# email tester for smtp
#
################################################################################

use utf8::all;
use Net::SMTP;
use MIME::Entity;

my $msg = "";

#############################################################################
# parse get/post
if ($ENV{'CONTENT_LENGTH'} || $ENV{'QUERY_STRING'}) {

    read(STDIN, my $buffer, $ENV{CONTENT_LENGTH});
    $buffer = $ENV{'QUERY_STRING'} if (!$buffer);

    my @pairs = split(/&/, $buffer);

    foreach my $pair (@pairs) {

      my ($name, $value) = split(/=/, $pair);
      $value = decode("utf-8",uri_unescape($value));

      # decode
      $value =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
      $value =~ s/\+/ /g;

      $F{$name} = $value;
      print STDERR qq!name: $namez\tvalue: $value\n!;
    }

} else {
    &printForm;
}

#############################################################################
# What to do
if ($F{'a'} eq "test email") {
    &sendEmail($F{'email'}, $F{'text'}, $F{'html'});
    &printForm($F{'email'}, $F{'text'}, $F{'html'});
} else {
    &printForm();
}
exit;



#############################################################################
sub printForm {

    # inputs: 0 - user's name, 1 - content text, 2 - content html


    my $out = qq |
<!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
  
    <title>Email Tester</title>
    <meta name="description" content="Test sendgrid is working">

    <!-- fonts
    ================================================== -->
    <link href="https://fonts.googleapis.com/css?family=Oswald:regular" rel="stylesheet" type="text/css">
  
    <link rel="stylesheet" href="/assets/css/normalize.css">
    <link rel="stylesheet" href="/assets/css/barebones.css">
    <link rel="stylesheet" href="/assets/css/skeleton-legacy.css">
    <link rel="stylesheet" href="/assets/css/local.css">
    <link rel="canonical" href="https://transitionelement.com/archives/2024/09/2024-09-27-peru_huayhuash_hike_day_1.html">
    <link rel="alternate" type="application/rss+xml" title="transitionelement" href="https://transitionelement.com/feed.xml">
<body>

  <!-- content -->
<div class="grid-container two-thirds">
  <div>

    <header>
    <h1>
        <a href="/" accesskey="1">
        <img src="/assets/images/transitionelement_logo_whit.gif" width="150" height="150" alt="transitionelement">
        </a>
    </h1>

    <nav class="nav">
    <ul class="nav-links">
        <li>
        <a class="nav-link" href="/archives/travel">travel</a></li>
        <li><a class="nav-link" href="/archives/culture">culture</a></li>
        <li><a class="nav-link" href="/archives/life-in-the-uk">life in the UK</a></li>
        <li><a class="nav-link" href="/archives/on-technology">on technology</a></li>
        <li><a class="nav-link" href="/archives/of-interest">of interest</a></li>
        <li><a class="nav-link" href="/archives/on-food-drink">on food &amp; drink</a></li>
        <li><a class="nav-link" href="/archives/hiking">hiking</a></li>
        <li><a class="nav-link" href="/archives">archives</a></li>
        <li><a class="nav-link" href="/info/colophon.html">about</a></li>
    </ul>
    </nav>

    <div class="search">
    <form action="/cgi-bin/search.cgi" method="get">
        <fieldset>
        <input name="a" value="search" type="hidden">
        <input id="search" name="q" size="20"><br>
        <input value="Search" type="submit">
        </fieldset>
    </form>
    </div>
</header>

  </div><!-- /end 2/3 -->
  <div>

    <h2>Send email test</h2>

    $msg

    <form method="get" action="/cgi-bin/comments.cgi">
        <fieldset>
            <label for="email">Email</label>
            <input type="email" id="email" name="email" value="$_[0]">
            <label for="text">Text</label>
            <textarea id="text" name="text">$_[1]</textarea>
            <label for="text">HTML</label>
            <textarea id="html" name="html">$_[2]</textarea><br>
            <input type="submit" name="a" value="test email" class="button-primary">
        </fieldset>
    </form>


  <!-- footer -->
<div class="grid-container two-thirds" role="contentinfo">
    <div></div>
    <div class="u-align-right">
        <small>
            Copyright © 1998-2024 Peter Mahnke
        </small>
    </div>
</div><!-- /grid-container two-thirds -->
</body>
</html>

  |;

  binmode STDOUT, ":utf8";
  print "Content-type: text/html; charset=UTF-8\n\n$out\n";

  return();

}

#############################################################################
sub email_comment {

    # email a comment for approval
    # inputs: 0 - user's name, 1 - content text, 2 - content html


    my $fe = qq|stmgrts.org.uk <forum\@stmgrts.org.uk>|;
    my $be = qq|peter\@stmgrts.org.uk|;

    my $subject = $_[0];
    my $body_text = $_[1];
    my $body = $_[2];

    # Login credentials
    my $username = "apikey";
    my $password ="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";

    # Open a connection to the SendGrid mail server
    $smtp = Net::SMTP->new('smtp.sendgrid.net',
                        Port=> 587,
                        Timeout => 60,
                        Hello => "stmargarets.london");

    # Authenticate
    $smtp->auth($username, $password);

    my $e = MIME::Entity->build(
                           From     =>$fe,
                           Reply-To =>$fe,
                           To       =>$be,
                           Encoding => '-SUGGEST',
                           Subject  =>$subject,
                           Type    =>'multipart/alternative'
                           );

    ### Add the text message part:
    ### (Note that "attach" has same arguments as "new"):
    $e->attach(
        Type     =>'text/plain',
        Encoding =>'-SUGGEST',
        Data     =>$body_text
        );

    $e->attach(
        Type     =>'text/html',
        Encoding =>'-SUGGEST',
        Data     =>$body
                 );

    # Send the rest of the SMTP stuff to the server
    $smtp->mail($fe);
    $smtp->to($be);
    $smtp->data($e->stringify);
    $smtp->quit();

    print STDERR qq |email: $body|;

    $msg = qq |<p class="box">Sent</p>|;

    return();

}