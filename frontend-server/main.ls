const { USER } = process.env
@include = ->
    @use \bodyParser, @app.router, @express.static __dirname
    @get '/roundtrip': ->
        res <~ reqToPg(@req)
        handleResponseFromPg.call @,res
    @get '/hi':  ->
        setupDatabase
        @response.send 200 "Database configurated"

setupDatabase = ->
        pg = require 'pg'
        conString = "tcp://#USER@localhost/#USER"
        client = new pg.Client conString
        client.connect!

        restInsert = """
            CREATE OR REPLACE FUNCTION rest (req json) RETURNS json AS $$
                return (#{ rest })(req);
            $$ LANGUAGE plv8 IMMUTABLE STRICT;
        """
        console.log "Injecting REST wrapper into database: \n#restInsert"
        client.query restInsert



# This function is never run in the Express webserver context. It's stringified
# and injected into postgres
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
