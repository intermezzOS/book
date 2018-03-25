#!/bin/bash

set -o errexit -o nounset

rev=$(git rev-parse --short HEAD)

# assemble the output
mkdir -p output/{first-edition,second-edition}

cp index.html output/index.html

mv first-edition/book/* output/first-edition/
mv second-edition/book/* output/second-edition/

# now deploy
cd output

git init
git config user.name "Steve Klabnik"
git config user.email "steve@steveklabnik.com"

git remote add upstream "https://$GH_TOKEN@github.com/intermezzOS/book.git"
git fetch upstream
git reset upstream/gh-pages

touch .
touch .nojekyll

git add -A .
git commit -m "rebuild pages at ${rev}"
git push -q upstream HEAD:gh-pages
