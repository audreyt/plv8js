#!/usr/bin/env lsc -cj
name: \frontend
description: 'Pg REST Frontend'
version: \0.0.1
homepage: 'https://github.com/audreyt/plv8js'
repository:
  type: 'git'
  url: 'https://github.com/audreyt/plv8js'
dependencies:
  pg: \*
  zappajs: \0.4.x
directories:
  bin: \./bin
scripts:
  start: 'lsc server.ls'
  prepublish: 'lsc -cj package.ls || echo'
engines:
  node: \0.8.x
