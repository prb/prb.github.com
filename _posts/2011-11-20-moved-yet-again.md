---
layout: post
title: "Moved Yet Again"
permalink: moved-yet-again.html
categories: [java, version]
---

I had been meaning to move this blog outside of the [mult.ifario.us](http://mult.ifario.us) domain for a while.  I initially thought about getting [perpubplat][perpubplat] updated to take account for newer versions of GHC and Twitter's switch to OAuth for API access and del.icio.us being deprecated (in favor of [Pinboard](http://pinboard.in)) and maybe [Akismet](http://akismet.com) integration and..., but that's a good bit of work for a project that is truly just for fun.

Instead, partially as an experiment for getting [FasterXML](http://fasterxml.com) content moved into [Github pages][githubpages] and partially because the push-to-publish workflow is appealing, I decided to give [Jekyll][jekyll] via Github pages a go as a replacement for [perpubplat].  It turns out that [perpubplat]'s post metadata is close enough to [Jekyll][jekyll]'s YAML [front matter](https://github.com/mojombo/jekyll/wiki/yaml-front-matter) that it's easy (~50 total lines of Scala) to write a quick conversion.  Permalinks that don't end in an unsightly `.html`, comments past and future, and tag-based navigation and feeds are all casualties of the conversion, and I'm OK with that.  (I've come around to the idea that _your_ comment is _your_ content, and if it's important enough, you can publish it somewhere else yourself.)

[jekyll]: http://github.com/mojombo/jekyll "Jekyll"
[perpubplat]: https://github.com/prb/perpubplat "perpubplat"
[githubpages]: http://pages.github.com "Github pages"