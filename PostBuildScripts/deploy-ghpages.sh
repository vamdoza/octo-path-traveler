#!/bin/sh

set -x

ls -l
export buildfolder="$(find . -regex '.\/temp[^\/]*\/default-webgl\/Build' -print -quit)"
if [ -z "$buildfolder" ]; then
  echo "Could not find build folder"
  exit 1
fi

if [ ! -d ./tmp ]; then
  git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}" ./tmp
fi
cp -r "$buildfolder" ./tmp
cd ./tmp
git add Build
git config --global user.name "$GITHUB_USER"
git commit -m "unity cloud build"
git push --force
