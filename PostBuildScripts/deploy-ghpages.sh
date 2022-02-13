#!/bin/sh
echo "====================DEPLOYMENT_TO_GITHUB_PAGES_START============================="
set -x

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
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$USER"
git add Build
git commit -m "unity cloud build $UCB_BUILD_NUMBER"
git log -1
git push --force

echo "====================DEPLOYMENT_TO_GITHUB_PAGES_END============================="