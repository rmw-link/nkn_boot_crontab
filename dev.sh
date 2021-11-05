#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")"; pwd)
set -ex
cd $DIR

direnv=./.direnv/bin/

. $direnv/pid.sh

if [ ! -n "$1" ] ;then
exe=./src/index.coffee
else
exe=${@:1}
fi

exec npx nodemon --watch './**/*' -e coffee,js,mjs,json,wasm,txt,yaml --exec "$direnv/coffee $exe"
