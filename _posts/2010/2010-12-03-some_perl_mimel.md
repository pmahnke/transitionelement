---
layout: post
title: "Some Perl MIME::Lite HTML Image Embedding"
permalink: /archives/2010/12/some_perl_mimel.html
commentfile: 2010-12-03-some_perl_mimel
category: on technology
date: 2010-12-03 20:43:03
---

At some point, you have been sent an HTML email with images that are still on the server. Most email clients will not download the images automatically, unless the sender is in your address book or been white-listed somehow. You either get:

### An email with no images, just empty boxes

<img src="/assets/images/Screen%20shot%202010-12-03%20at%2020.17.05.png" width="615" height="98" class="photo center" alt="email, no images"/>

or,

### An email with no images, empty boxes and a message asking you if you want to download them.

<img src="/assets/images/Screen%20shot%202010-12-03%20at%2020.19.54.png" width="417" height="45" class="photo center" alt="email, download first"/>

This is for good reason, nasty marketers can embedded tracking codes and who knows what else (joke)...

Of course, the real solution to this is, _send plain text or rich text emails_; however, I realise there are times when an HTML email is the only think that will make the boss and the design team happy. Specially for the company Christmas email.

So I have ended up coding a web form that allows people add the To:, From:, Subject: and a personal message to our email, but it needs to send our nice corporate image too.

<img src="/assets/images/xmas_image_2010.gif" width="600" height="400" class="photo center" alt=" Scholastic Xmas emailer 2010" />

Using [MIME::Lite](http://search.cpan.org/~rjbs/MIME-Lite-3.027/lib/MIME/Lite.pm), you can easily send these images with a [multipart/mixed](http://en.wikipedia.org/wiki/MIME#Mixed) email. Basically, you make the image source point to a file "cid:&lt;filename&gt;" and then attach that &lt;filename&gt;. However, I figured, you might get a lot of image files in your HTML email and some might not even be local.

_What a pain it would be to hand code these up every time!_

So I wrote a script that:

1.  parses the HTML looking for &lt;img tags
2.  if it finds one, it checks if the file is local or remote
    1.  if it is remote, it _wget_ the file and makes it a local one (you have to delete these later)
3.  then it turns the source of the image to the correct new one &lt;img src="cid:
4.  finally, it attaches the file, using [base64](http://en.wikipedia.org/wiki/Base64)

Now this will work for any HTML email I send, not just the Christmas card. The benefits are:

- less chance of the email being flagged as SPAM
- better chance someone will see the HTML email
- happier boss and design people

Here is some code...

    <code>
    ################################################################################
    sub email {

        # Create the multipart "container":

        MIME::Lite->send("sendmail", "/usr/sbin/sendmail -t -oi -oem >& /dev/null");
        $msg = MIME::Lite->new(
           From    =>$FORM{'from'},
           Cc      =>$FORM{'cc'},
           Bcc     =>$FORM{'bcc'},
           Subject =>$FORM{'subject'},
           Disposition => 'inline',
           Type    =>'multipart/related'
           );
        $msg->attr("content-type.charset" => "UTF-8");


        # parse the images in the HTML
        my $html = &parseHTMLinlineImages($FORM{'html'});

        # convert to utf8, not a requirement for everyone....
        $html = encode("utf8", $html);

        # Add the html itself:
        $msg->attach(
           Type     =>'text/html',
           Data     => $html,
           );

        $msg->scrub(['content-disposition', 'content-length']);
        $msg->send;

        return();
    }

    ################################################################################
    sub parseHTMLinlineImages {

        # input 0 - html

        my ($in, $out);
        my @lines = split (/\n/, $_[0]);

        foreach (@lines) {

            if (/<img/) {

                # in image tag
                if (/src="(.[^"]*)"/i) {

          # deal with the image itself
          my $img = &prepAttachImg($1);

          # change the html to reference the attached image
          # e.g. <img src="cid: ... " .../>
          s/$1/cid:$img/g;
                }
            }
            $out .= "$_\n";
        }
        return($out);
    }

    ################################################################################
    sub prepAttachImg {

        # deal with physical images and make them into MIME::Lite attachments

        my $/assets/images/ = $_[0];
        my ($filename, $fileloc) = "";

        $filename = basename($/assets/images/); # using File::Basename to get the file name only

        # see if local or not
        if ($/assets/images/ =~ /http/) {

            # not local, so wget the file, etc...
            $fileloc = "/tmp/".$filename; # where to save the file

            # test to see if we already have it
            if (!-e "$fileloc") {

                # no it isn't already in tmp, so wget it
                `/usr/bin/wget --quiet --output-document=$fileloc $/assets/images/`;

            }

        } else {

            # test if it is actually where we think it should be on the server
            if (!-e "$/assets/images/") {

                # file not found
                $mesg .= qq |file not found<br />$/assets/images/ $filename|;
                &printERROR();
                exit;

            } else {

                # is it on the srever where it says, so don't even move it...
                $fileloc = $/assets/images/;

            }
        }

        # set the mime type for MIME::Lite
        my $mimetype = $1 if ($/assets/images/ =~ /\.(gif|jpg|png)/);
        $mimetype = "jpeg" if ($mimetype =~ /jpg/i);

        # attach it to the already open $msg
        $msg->attach(
            Type => 'image/'.$mimetype,
            Id   => $filename,
            Path => $fileloc,
        );

        return($filename); # return the pathless filename

    }
    </code>
