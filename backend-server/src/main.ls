DB = {}

{List, Task} = require \./model

{select, ProtoList} = require \./eval

@include = ->
    @use \bodyParser, @app.router, @express.static __dirname

    @appname = 'Today'
    modelmeta = { Task: {}, List: {}}

    l = new List <<< ProtoList
    t = new Task <<< _List: l._id
    memstore = { Task: [t], List: [l] }

    findOne = (model, id) ->
        [object] = memstore[model].filter -> it._id is id
        return object

    @get '/database/:appname/collections/:model/:id': ->
        @response.send 200 findOne ...@params<[model id]>

    @post '/database/:appname/collections/:model': ->
        @response.send 200 new Task.Create {_List: \fooo }

    @put '/database/:appname/collections/:model/:id': ->
        if @params.id is \_
            modelmeta[@params.model] = @body
            @response.send 200 @body
        else
            object = findOne ...@params<[model id]>
            object <<< @body
            @response.send 200 object

    @del '/database/:appname/collections/:model/:id': ->
        @response.send 200 \notyet

    @get '/database/:appname/collections/:model': ->
        @response.send 200 select memstore, @params.model
