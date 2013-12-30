About
=====

So how did Scorched come to be? It began as a result of using Sinatra - and subsequently Padrino - on a council web application for managing cemeteries. The numerous excel spreadsheets the system was replacing resulted in more than one instance of someone being buried in the wrong hole.

I had previous experience with Sinatra, but not with anything of scale. Early in the project I made the move from Sinatra to Padrino as I wanted to split out my growing collection of routes into discreet controllers. I didn't want all my helpers, views, filters, etc, to be lumped into one big global controller, which would have quickly turned into frustrating and unmaintainable mess.

It wasn't long after the switch to Padrino that I realised that what Padrino called a controller, wasn't quite what I had in mind. This proved to be point of frustration as I continued adding more functionality to my application. This marked the beginning of a personal quest to find a better alternative, which in most cases results in me rolling my own when I inevitably fail to find anything to my taste.

From when I made the decision to roll-my-own, to the moment I pushed up version 0.1, easily half of that time was spent conceptualising. I hate being called a perfectionist, but I certainly have a preference for quality, so it was important that Scorched be implemented as thoughtfully as the language it was written in, Ruby.

In hind-sight, what Scorched has turned into is some kind of modular, inheritable, nest-able version of Sinatra, with even less opinion and bloat.


ScorchedRb.com
--------------
You can get a copy of the source code for this website, or even contribute to it over at [Github](http://github.com/Wardrop/ScorchedRb.com). It should serve as another example of Scorched in action, albiet a relatively simple one. In addition to Scorched, this website is also powered by:

* Xen VM with 768 MB RAM and 1 vCPU
* OpenSUSE 12.3
* Nginx
* Phusion Passenger Enterprise
* Ruby 2.0
* Git

Everything under docs is pulled from the ``docs/`` directory of the Scorched Github repository. At the same time, the README is also pulled over to form the home page. This sync happens every half hour, and on re-deployment. Deployment is achieved by pushing to a bare git repository on this server, with a ``post-receive`` hook script configured to checkout to the production directory, run bundler, and restart the app among a few other things.

I'd like to add that this website is also IPv6-ready. I've got my subnet of 16 million IPv6 addresses assigned and ready to go.


The Author
----------
I'm <a href="http://tomwardrop.com">Tom Wardrop</a>. A web-enthusiast and developer, based in Australia. I'm currently employed as a software developer at my local Council. About 60% of my job involves dealing with Ruby, linux and other web technologies, whilst the other 40% is spent in the world of Microsoft, and my arch nemesis, SharePoint.

It's ironic. SharePoint and Scorched could not be further apart in terms of architecture and design philosophy. It seems for SharePoint, the focus is on what's implemented, rather than how it's implemented, and this results in the most bloated, inelegant web application I've come to know. But it does integrate with Office, sometimes... assuming your office version coincides the version of SharePoint, and that you're using Internet Explorer, and that _n_ other conditions are met, but this is all I can attribute to its success. I do have software like SharePoint to thank for providing powerful insight into exactly why they're so terrible, and using that to better my own knowledge, skills and judgement of other software, especially that which I make.

I intend to start a blog, mostly about web development and general philosophy, with the occasional rant about SharePoint and what we can all learn (or not learn) from it.

If you want to email me about anything, you can get me on: <a href="mailto:tom@tomwardrop.com">tom@tomwardrop.com</a>

Sponsorship
-----------
Scorched is currently sponsored by [Phusion](http://www.phusion.nl), developers of the well-known Passenger application server for Nginx and Apache. They've supplied me with courtesy copies of Phusion Passenger Enterprise. Having Phusion Passenger Enterprise will enable me to get the most out of the budget Australian-hosted virtual server hosting this website, and allow me to test Scorched in a range of different multi-threaded, multi-process scenarios to ensure compatibility.

I thank Phusion for helping an open-source framework like Scorched get off the ground.