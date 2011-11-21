---
layout: default
title: Archive
permalink: archive.html
---
+-- {.nav}
\[[front](/)\]
=--

+-- {.compact .recent}
{% for post in site.posts %}
* {{ post.date | date: "%Y-%m-%d" }} — [{{ post.title }}]({{ post.url }})
{% endfor %}
=--