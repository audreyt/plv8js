DB = {}

@include = ->
    pgClient = setupDatabase!
    @use \bodyParser, @app.router, @express.static __dirname
