models = {List, Task} = require \./model
{select, ProtoList} = require \./eval
require! \fs

@include = ->
    @use \bodyParser, @app.router, @express.static __dirname + "/../_public"

    appname = 'Today'
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

    @get '/': ->
        @res.send 200 <[ db databases ]>

    for verb in <[put post del]> => let orig = @[verb]
        @[verb] = ->
            wrapped = (ov) -> ->
                ov.call @, ...
                save!
            orig.call @, { [k, wrapped v] for k, v of it }

    for verb in <[get put post del]> => let orig = @[verb]
        @[verb] = ->
            return orig.call @, ... unless typeof it is \object
            orig.call @, { ["/databases#k", v] for k, v of it }
            orig.call @, { ["/db#k", v] for k, v of it }

    @get '': ->
        @res.send 200 [appname]

    @get '/:appname': ->
        @res.send 200 { collections: [k for k of models] }

    @get '/:appname/collections': ->
        @res.send 200 [k for k of models]

    @get '/:appname/collections/:model/:id': ->
        {id, model} = @params
        res = select memstore, model, -> it._id is id
        return @res.send 404 {error: "No such ID"} unless res.length
        @res.send 200 res.0

    @get '/:appname/collections/:model/:id/:field': ->
        {id, model, field} = @params
        res = select memstore, model, -> it._id is id
        return @res.send 404 {error: "No such ID"} unless res.length
        @res.send 200 res.0[field]

    @post '/:appname/collections/:model': ->
        object = new models[@params.model] <<< @body
        memstore[@params.model].push object
        @res.send 201 object

    @put '/:appname/collections/:model/_': ->
        modelmeta[@params.model] = @body
        @res.send 200 @body

    @put '/:appname/collections/:model/:id': ->
        object = findOne ...@params<[model id]>
        object <<< @body
        @res.send 200 object

    @del '/:appname/collections/:model/:id': ->
        {id, model} = @params
        memstore[model] = memstore[model].filter -> it._id isnt id
        @res.send 201 null

    @get '/:appname/collections/:model': ->
        @res.send 200 select memstore, @params.model
