#!/usr/bin/env lsc -cj
name: \backend
description: 'postgre.st backend'
version: \0.0.1
homepage: 'https://github.com/audreyt/plv8js'
repository:
  type: 'git'
  url: 'https://github.com/audreyt/plv8js'
dependencies:
  zappajs: \0.4.x
  nodemon: \*
  uuid-v4: \*
  request: \*
directories:
  bin: \./bin
scripts:
  start: 'make run'
  prepublish: """
  lsc -cj package.ls || echo
  lsc -bc .
  """
engines:
  node: \0.8.x
