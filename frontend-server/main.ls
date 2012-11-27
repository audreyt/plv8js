@include = ->
    @use \bodyParser, @app.router, @express.static __dirname
    @get '/': \hi
    @get '/REQ': ->
        simpleRequest = {
            method: @request.method,
            url: @request.url,
            headers: @request.headers,
        }
        @response.json 200 simpleRequest
    @get '/hi':  ->
        pg = require 'pg'

        conString = 'tcp://jesse@localhost/postgres'

        client = new pg.Client conString

        client.connect!

        client.query 'CREATE TEMP TABLE beatles(name varchar(10), height integer, birthday timestamptz)'

        client.query 'INSERT INTO beatles(name, height, birthday) values($1, $2, $3)', [
          'Ringo'
          67
          new Date 1945, 11, 2
        ]

        client.query 'INSERT INTO beatles(name, height, birthday) values($1, $2, $3)', [
          'John'
          68
          new Date 1944, 10, 13
        ]

        _, result <~ client.query 'SELECT * from beatles'
        @response.json 200 result
