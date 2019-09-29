---
layout: post
title: "XPath and me"
permalink: /archives/2010/11/xpath_and_me.html
commentfile: 2010-11-06-xpath_and_me
category: on technology
date: 2010-11-06 13:07:37

---

I run a small, hyperlocal website, [St Margarets Community Website](http://stmgrts.org.uk). I do this completely in my *spare* time and am always looking for ways to cut corners. One bit time suck is posting events where you have to:

-   get the event text (sometimes emailed, sometimes on a website, sometimes on a postcard)
-   clean the text, specially if it is in an email, word or pdf into ascii with proper line breaks)
-   prepare any images or pdfs (if the event is complex) and resize them, upload them, add the right classes, alt text, etc...)
-   upload the image
-   copy and paste all the events into the event database via web form (and this form is pretty optimised, with a host of all the hosts and venues and date pickers and checkboxes, etc... to make it easy as possible)

If I am really moving, I can get it done in about 10-20 minutes. I have done over 2,300 in the past five years... that averages to 575 hours or 24 days of my life!

Therefore, I always try to cut corners. I tried getting volunteers, but strangely, they always seem to abandon me. The only method I have come up with is, you guessed it (the title helps) screen scraping. At some point, you recognise that some of the events you post are from sites big enough to have their own databases, generating regular html. They also have the most events, so there is a real potential benefit in writing a parser. The problem is, any change in the underlying code and the whole parser breaks. What a pain!

So, yes, after building websites for 15 years, I am still screen scraping -- in Perl. I have tried various parsing modules, but usually end up hand coding it. This was until I helped a friend write a parser for another project in ruby. He had started using XPath. It was a revelation.

So after helping [my friend](http://omarqureshi.net/) I decided to look at the Perl versions. I quickly rejected [XML::Xpath](http://search.cpan.org/~msergeant/XML-XPath-1.13/XPath.pm) as none of the html I was looking at validated. I quickly found [HTML::TreeBuilder::XPath](http://search.cpan.org/~mirod/HTML-TreeBuilder-XPath-0.12/lib/HTML/TreeBuilder/XPath.pm). It has helped me enormously by taking the pain out of parsing. You can easily get anyway in the DOM and get your text. This means, it is no longer a huge effort to update the parser if the html changes. It also makes the code far more readable and far smaller.

#### Here is an example of what I mean

Here is the code to get some event listings off a theatre page.

    <code>

        foreach (@lines) {

            last if ($FLAG_in == 2 && /(<p>|img /assets/images/)/);

            if ($FLAG_in == 1 && /<table/) {
               # out of dates
                $FLAG_in = 0;
                next;
            }

            if (/<p><b>Performances:<\/b><br><br>/) {
                # in dates
                $FLAG_in = 1;
                next;
            }

            if ($FLAG_in == 1 && /<b>\&nbsp\;\&nbsp\;(.*) (.*) (.[<sup>\:]*):<\/b> \&nbsp\;(.[</sup><]*)</) {
                # date info
                $dow  = $1;
                $date = $2;
                $mon  = $3;
                $time = $4;
                $early_date = $date if ($date < $early_date || !$early_date);
                $last_date  = $date if ($date > $last_date && $month ne $mon);
                $last_date  = $date  if ($mon ne $end_mon);
                $start_mon = $mon if (!$start_mon);
                $end_mon   = $mon if (!$end_mon || $mon ne $end_mon);

                if ($start_mon =~ /(Jan|Feb|Mar)/) {
                    $cur_year = $year + 1;
                } else {
                    $cur_year = $year;
                }

                if ($start_mon =~ /(Jan|Feb|Mar)/) {
                   $end_year = $year + 1;
                } else {
                   $end_year = $cur_year;
                }

                $early_date - $last_date $months{$start_mon} - $months{$end_mon} $cur_year - $end_year\n\n";
            }

            if (/<span class\=\"prod_title\">(.[^<]*)</) {
                # found play title
                $title   = $1;
                $FLAG_in = 2;
                next;
            }

            next if (!$FLAG_in);

            $blurb .= $_."\&\&\&\&\&" if ($FLAG_in == 2);

        }

    </code>

Ok, so I am obviously not a programmer by training, but you can see, there is a lot of brute force regular expression work and lots of logic to know where you are in the document. It isn't pretty and is *very* fragile.

But with XPath, it is completely different. That whole set of code becomes (with a slightly different version of the core html).

    <code>

        my $in = HTML::TreeBuilder::XPath->new_from_content($_[0]);

        @urls        = $in->findvalues('//ul[@class="multiple_columns"]//a/@/assets/images/');
        @imgs        = $in->findvalues('//ul[@class="multiple_columns"]//a/div/@style');
        @titles      = $in->findvalues('//div[@class="resbox_title"]/span[@class="resbox_production"]');
        @start_dates = $in->findvalues('//div[@class="resbox_dates"]/span[contains(@id,"StartDate")]');
        @end_dates   = $in->findvalues('//div[@class="resbox_dates"]/span[contains(@id,"ExpireDate")]');


    </code>

That is 9 lines of code compared to 64 lines, that is 85% smaller! It is also more readable as there is no logic. Another thing not visible in these snippets is that I can use UTF8 and Encode to just accept the text as it is far more easily.

So, if you are still screen scraping, I recommend looking at XPath.
