---
layout: post
title: "MT Textile SelfLoader Error"
permalink: /archives/2011/06/mt_textile_self.html
commentfile: 2011-06-22-mt_textile_self
category: on technology
date: 2011-06-22 22:49:21
---

Today I did some general CPAN updates. Everything went fine, I thought, but when I attempted to publish a post to this blog with Movable Type 3.38, I kept getting this error:

```
An error occurred:
Global symbol "$nested" requires explicit package name at (re\_eval 34) line 2, &lt;DATA&gt; line 1.
Compilation failed in regexp at /usr/lib/perl5/5.8.8/SelfLoader.pm line 112, &lt;DATA&gt; line 1.
```

After a minor amount of digging, I found it was either SelfLoader.pm or Textile2.

```
perl -MSelfLoader -e 'print 1'
```

returned '1'

I attempted to upgrade to the MT 4.X versions of textile2, but MT 3 didn't recognise it at all.

So, I just added ...

```
my $nested = "";
```

... to SelfLoader.pm and it works.

Who knows if that will cause other errors later, but it all works now.

Hope this might help someone else.
