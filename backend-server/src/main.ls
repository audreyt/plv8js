DB = {}

{List, Task} = require \./model

@include = ->
    @use \bodyParser, @app.router, @express.static __dirname

    @get '/database/Today/collections/:model/:id': ->
        @response.send 200 new Task!

# list
#    @get '/database/Today/collections/:model': ->
