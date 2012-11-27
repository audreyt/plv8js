@include = ->
    @use \bodyParser, @app.router, @express.static __dirname
    @get '/': \hi
    @get '/roundtrip': ->
        res <~ reqToPg(@req)
        console.log res
        @response.json 200 res
    @get '/REQ': ->
        @response.json 200 simplifyRequest(@req)
    @get '/hi':  ->
        pg = require 'pg'
        conString = 'tcp://jesse@localhost/jesse'
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


simplifyRequest = ->
        JSON.stringify it{method, url, query, params, headers, body }

reqToPg = (req, cb) ->
        pg = require 'pg'
        conString = 'tcp://jesse@localhost/jesse'
        client = new pg.Client conString
        client.connect!
        err, result <~ client.query 'SELECT rest($1) as res' [ simplifyRequest req ]
        console.log result
        console.log err

        cb JSON.parse result.rows.0.res



