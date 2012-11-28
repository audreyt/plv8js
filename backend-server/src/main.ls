models = {List, Task} = require \./model
{select, ProtoList} = require \./eval
require! \fs

@include = ->
    @use \bodyParser, @app.router, @express.static __dirname

    @appname = 'Today'
    modelmeta = { Task: {}, List: {}}

    memstore = try JSON.parse fs.readFileSync \dump.json \utf8

    l = new List <<< ProtoList
    t = new Task <<< _List: l._id
    memstore ?= { Task: [t], List: [l] }

    findOne = (model, id) ->
        [object] = memstore[model].filter -> it._id is id
        return object

    save = ->
        fs.writeFileSync do
            "dump.json"
            JSON.stringify memstore
            \utf8

    for verb in <[put post del]> => let orig = @[verb]
        @[verb] = ->
            wrapped = (ov) -> ->
                ov.call @, ...
                save!
            orig.call @, { [k, wrapped v] for k, v of it }

    @get '/database/:appname/collections/:model/:id': ->
        @response.send 200 findOne ...@params<[model id]>

    @post '/database/:appname/collections/:model': ->
        object = new models[@params.model] <<< @body
        memstore[@params.model].push object
        @response.send 201 object

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
