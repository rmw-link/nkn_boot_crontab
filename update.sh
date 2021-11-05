#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")"; pwd)
set -ex
cd $DIR

if [ ! -d $DIR/node_modules ] ; then
pnpm install --only=prod
fi

gitlib=rmw-link/nkn_boot.git

git clone git@github.com:$gitlab data --depth=1

node lib/index.js

