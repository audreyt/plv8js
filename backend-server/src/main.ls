DB = {}

{List, Task} = require \./model

@include = ->
    @use \bodyParser, @app.router, @express.static __dirname

    @appname = 'Today'
    modelmeta = { Task: {}, List: {}}
    memstore = { Task: [], List: [] }

    @get '/database/:appname/collections/:model/:id': ->
        @response.send 200 new Task {_id: @params.id }

    @post '/database/:appname/collections/:model': ->
        @response.send 200 new Task.Create {_List: \fooo }

    @put '/database/:appname/collections/:model/:id': ->
        if @params.id is \_
            modelmeta[@params.model] = @body
            @response.send 200 @body
        else
            @response.send 200 \notyet

    @del '/database/:appname/collections/:model/:id': ->
        @response.send 200 \notyet

    @get '/database/:appname/collections/:model': ->
        @response.send 200 \notyet
