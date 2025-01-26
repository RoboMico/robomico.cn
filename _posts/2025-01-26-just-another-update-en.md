---
title: Just Another Update of the Website
date: 2025-01-26 14:55:12 +0800
categories: [Announcements]
tags: [en]
lang: en
---

Due to my limited time and energy (senior grade in high school, you know), this site has been lacking in maintenance for a few months. I was planning to do some *small* clean up during my winter break, but I didn't realize how heavy the technical liabilities are:

- GitHub Pages have long been having a poor accessibility in China which puts a great inconvenience on my intended readers;
- OneDrive blocked direct links using `authkey` and bombed up all the pictures and files on my site;
- Chirpy theme upgraded to 7.2.4. Though the appearance didn't change much, the SCSS files were completely restructured and my patches can not be merged easily;
- ……

So I have to spend a whole day remaking the site from scratch.

- The repo was rebased to 7.2.4 release of the upstream, because merging branches is just pure pain
  - Re-edited SCSS files and HTML layouts, as well as cleaned up some sh!t codes
  - The commits history is lost but I think nobody cares `¯\_(ツ)_/¯`
- Introduced `jekyll-paginator-v2` to add paging function for post list
- The site is not hosted on Cloudflare Pages. You can always trust their global CDN!
- Static files on the site are now hosted on Cloudflare R2. ~~(cloudflare you are my father)~~
- All files provided by jsdelivr are now linked to mirror sites. This shouldn't make any difference for most of the international readers, since they can be redirected to original links when appropriate.
- Some posts are gone but I won't tell you why :P

Anyway wish this site could live longer and more content will be provided in the future!

Wish you an early Happy Year of Snake! 🐍
