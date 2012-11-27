const { USER } = process.env
@include = ->
    @use \bodyParser, @app.router, @express.static __dirname
    @get '/': \hi
    @get '/roundtrip': ->
        res <~ reqToPg(@req)
        handleResponseFromPg.call @,res
    @get '/REQ': ->
        @response.json 200 simplifyRequest(@req)
    @get '/hi':  ->
        pg = require 'pg'
        conString = "tcp://#USER@localhost/#USER"
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

        console.log """
            CREATE OR REPLACE FUNCTION rest (req json) RETURNS json AS $$
                return (#{ rest })(req);
            $$ LANGUAGE plv8 IMMUTABLE STRICT;
        """
        client.query """
            CREATE OR REPLACE FUNCTION rest (req json) RETURNS json AS $$
                return (#{ rest })(req);
            $$ LANGUAGE plv8 IMMUTABLE STRICT;
        """

        _, result <~ client.query 'SELECT * from beatles'
        @response.json 200 result

rest = ->
    JSON.stringify do
        status-code: 200
        type: \application/json
        headers:
            'X-Server': 'PostgreSQL'
        body:
            orig: JSON.parse it
            extra: \nice

simplifyRequest = ->
        JSON.stringify it{method, url, query, params, headers, body }

reqToPg = (req, cb) ->
        require! pg
        conString = "tcp://#USER@localhost/#USER"
        client = new pg.Client conString
        client.connect!
        err, result <~ client.query 'SELECT rest($1) as res' [ simplifyRequest req ]
        console.log result
        console.log err
        cb JSON.parse result.rows.0.res

handleResponseFromPg = ({headers,type,statusCode,body}) ->
    for k,v of headers => @response.set k,v
    @response.type type
    @response.send statusCode, body
