---
layout: post
title: "Killing Spam with Mailfront and CVM"
permalink: /archives/2005/10/killing_spam_wi.html
commentfile: 2005-10-28-killing_spam_wi
image: "/assets/images/mailfront05-thumb.gif"
category: on technology
date: 2005-10-28 21:28:23
---

I manage the email for a 20 or so domains. A long time ago I moved everything to [qmail](http://www.qmail.org/l) with [vmailmgr](http://www.vmailmgr.org/) which I love, despite how hard it has been to get up and running as a non-programmer. The combination of safely and flexibility of the combination have been great. The problems have really been around all the other 'stuff' that you really need; IMAP (Courier), Span filters (SPAM ASSASSIN), etc... all of which have their own complexities and the start-up scripts start getting insane -- for me anyway.

However, there is one set of scripts that I have added that have made my life and my CPU's immeasurably better -- [Mailfront](http://untroubled.org/mailfront/) and [CVM](http://untroubled.org/cvm/). These two together can reject an email before it even hits the email system, in my case Qmail, by seeing if the incoming email is a real user on the system or not. It doesn't stop Spam to an account, but it will reject all the 'dictionary spammers' or whatever you call the people who hit every name in the baby book at every domain... This might seem simplistic, but if the email hits Qmail, it can sit there for something like 7 days. If you get a few thousand of these, it can really hurt the system -- not to mention all the additional Spam Assassin time, etc..

Considering we get something short of 7 times more emails to addresses that don't exist that do, this is a lifesaver and has really helped our system's performance.

If you manage an email server, I _strongly_ recommend you look into these tools.
