---
layout: post
title: "W Wh Who Whoa! "
permalink: /archives/2011/06/w_wh_who_whoa_1.html
commentfile: 2011-06-22-w_wh_who_whoa_1
category: on technology
date: 2011-06-22 18:46:02
---

<a href="/assets/images/Google-Chrome-icon.png"><img alt="Google-Chrome-icon.png" src="/assets/images/Google-Chrome-icon-thumb.png" width="150" height="150" class="span-4 right" /></a>

I love [Google Chrome](http://www.google.com/chrome/intl/en-GB/more/features.html). It has just introduced a new super-fast page loading feature called [Prerendering](http://blog.chromium.org/2011/06/prerendering-in-chrome.html) that tries to guess what you are looking for and gets it in the background. It is really fast. However, if you type a bit slow, it does have a tendency to just try and get whatever bit of the url you have typed.

For example, I was trying to go to [www4.scholastic.co.uk/warehousesale](https://www.scholastic.co.uk/warehousesale) and happened to be tailing the error log and found this:

    [Wed Jun 22 12:41:47 2011] [error] File does not exist: /var/www/html/warehousesal
    [Wed Jun 22 12:41:48 2011] [error] File does not exist: /var/www/html/warehou
    [Wed Jun 22 12:41:48 2011] [error] File does not exist: /var/www/html/wareho
    [Wed Jun 22 12:41:48 2011] [error] File does not exist: /var/www/html/wa

Now, this single request really didn't take too much time or CPU, but I can imagine, with loads of people moving to Chrome, this could really start adding up to real CPU and network bandwidth.

What do other people think?
