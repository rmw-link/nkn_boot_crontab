#!/usr/bin/env coffee

import { nodeExternalsPlugin } from 'esbuild-node-externals'
import coffee from 'esbuild-coffeescript'
import esbuild from 'esbuild'
import path from 'path'

ROOT = path.dirname(new URL(import.meta.url).pathname)

DEV = process.env.NODE_ENV != "production"

opt = {
  platform:"node"
  bundle: true
  format:'esm'
  plugins: [
    coffee()
    nodeExternalsPlugin()
  ]
  define:{
    DEV
  }
  external:[
    'nkn-sdk'
    'better-sqlite3'
  ]
  entryPoints: [
    path.join(ROOT,'src/index.coffee')
  ]
  outfile: path.join(ROOT,'lib/index.js')
}

if DEV
  opt.sourcemap = 'inline'
else
  opt.minify = true

esbuild.build opt




