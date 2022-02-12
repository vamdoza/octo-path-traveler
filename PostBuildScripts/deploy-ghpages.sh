#!/bin/sh

set -x

ls
export buildfolder="$(find . -regex '.\/temp[^\/]*\/default-webgl' -print -quit)"
if [ -z "$buildfolder" ]; then
  echo "Could not find build folder"
  exit 1
fi

if [ ! -d ./tmp ]; then
  git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}" ./tmp
fi
cp -r "$buildfolder/." ./tmp
cd ./tmp
git status
git remote -v
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"
git add *
git status
git commit -m "unity cloud build"
git status
git log -3
git push --force
git status