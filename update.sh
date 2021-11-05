#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")"; pwd)
set -ex
cd $DIR

if [ ! -d $DIR/node_modules ] ; then
pnpm install --only=prod
fi

node lib/index.js

