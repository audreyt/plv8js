#!/usr/bin/env lsc
slurp = -> require \fs .readFileSync it, \utf8
argv = (try require \optimist .argv) || {}
port = Number(argv.port) or 8888
host = argv.host or \0.0.0.0
basepath = (argv.basepath or "") - //  /$  //

{ keyfile, certfile, key, polling } = argv

transport = \http
if keyfile? and certfile?
    options = https:
        key: slurp keyfile
        cert: slurp certfile
    transport = \https

console.log "Please connect to: #transport://#{
    if host is \0.0.0.0 then require \os .hostname! else host
}:#port/"

<- (require \zappajs) port, host, options
@include \main
