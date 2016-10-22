#!/bin/bash

rm -rf dist
elm-make Main.elm --warn --output=dist/main.js
cp index.gh-pages.html dist/index.html
cd dist
git init
git add .
git commit -m "Deploy to Github Pages"
git push --force git@github.com:cbenz/youtube-dl-audio.git master:gh-pages
