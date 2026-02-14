#!/usr/bin/env bash
#
# For Cloudflare Workers building the site

echo "[/home/robomico/constructor] Installing NPM Packages..."
npm i

echo "[/home/robomico/constructor] Installing bundle..."
bundle install

echo "[/home/robomico/constructor] Building JS scripts..."
npm run build

echo "[/home/robomico/constructor] Building website..."
JEKYLL_ENV=production bundle exec jekyll build

echo "[/home/robomico/constructor] Done!"
