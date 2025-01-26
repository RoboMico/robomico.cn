#!/usr/bin/env bash
#
# For Cloudflare Workers building the site

npm i
bundle install
npm run build
JEKYLL_ENV=production bundle exec jekyll build
