DB = {}

@include = ->
    @use \bodyParser, @app.router, @express.static __dirname
