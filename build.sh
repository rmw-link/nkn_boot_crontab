#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")"; pwd)
set -ex
cd $DIR

NODE_ENV=production ./build.coffee

