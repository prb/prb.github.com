---
layout: default
title: Home
permalink: index.html
---

## Recent Posts

{% for post in site.posts limit: 10 %}
* {{ post.date | date: "%Y-%m-%d" }} &mdash; <a href="{{ post.url }}">{{ post.title }}</a>
{% endfor %}

For older posts, go to the [archives]({{ site.url }}/archive.html).

## Other

I work at [Multifarious, Inc.](http://mult.ifario.us) and [FasterXML](http://fasterxml.com).

You can also find me:

* [Twitter](http://twitter.com/paulrbrown)
* [LinkedIn](http://www.linkedin.com/in/paulrbrown)
* [Github](https://github.com/prb)

This site is published using [Github pages](http://pages.githib.com) and the [Jekyll](https://github.com/mojombo/jekyll) static site generator.  The source is [available](https://github.com/prb/prb.github.com).
