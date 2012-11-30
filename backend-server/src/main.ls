models = {List, Task} = require \./model
{select} = require \./eval
require! \fs

modelmeta = do
    List: do
        tasks:              $from: \Task
        tasksAddedAtStart:  $from: \Task $query: CreatedAt: $: \CreatedAt
        tasksAddedAtLater:  $from: \Task $query: CreatedAt: $gt: $: \CreatedAt
        completeTasks:      $from: \Task $query: { +Complete }
        incompleteTasks:    $from: \Task $query: { -Complete }
        isFinalized:        $: CreatedAt: $gt: $ago: 18hr * 3600s * 1000ms

@include = ->
    @use \bodyParser, @app.router, @express.static __dirname + "/../_public"

    appname = 'Today'

    memstore = try JSON.parse fs.readFileSync \dump.json \utf8
    memmeta  = try JSON.parse fs.readFileSync \meta.json \utf8

    l = new List
    t = new Task <<< _List: l._id
    memstore ?= { Task: [t], List: [l] }

    memmeta ?= modelmeta

    findOne = (model, id) ->
        [object] = memstore[model].filter -> it._id is id
        return object

    save = ->
        fs.writeFileSync do
            "meta.json"
            JSON.stringify memmeta
            \utf8

        fs.writeFileSync do
            "dump.json"
            JSON.stringify memstore
            \utf8

#    @get '/': ->
#        @res.send 200 <[ db databases ]>

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
        res = select memmeta, memstore, model, filter: -> it._id is id
        return @res.send 404 {error: "No such ID"} unless res.length
        @res.send 200 res.0

    @get '/:appname/collections/:model/:id/:field': ->
        {id, model, field} = @params
        res = select memmeta, memstore, model, filter: -> it._id is id
        return @res.send 404 {error: "No such ID"} unless res.length
        @res.send 200 res.0[field]

    @post '/:appname/collections/:model': ->
        m = models[@params.model] ?= null
        object = if m => new m <<< @body else @body
        memstore[][@params.model].push object
        @res.send 201 object

    @put '/:appname/collections/:model/_': ->
        memmeta[@params.model] = @body
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
        { q: query, c: count, f: fields, fo: firstOnly, s: sort, sk: skip, l: limit } = @query ? {}
        @res.send 200 select memmeta, memstore, @params.model, {
            query: try JSON.parse(query ? \null)
            count, fields, firstOnly, sort, skip, limit
        }

    singularize = (x) -> "#x".replace(/ies$/ 'y').replace(/s$/, '').replace(/^./, -> it.toUpperCase!)

    # CargoCulting, refactor later
    @post '/:appname/collections/:pmodel/:pid/:model': ->
        model = singularize @params.model
        m = models[model] ?= null
        object = if m => new m <<< @body else @body
        object["_#{ @params.pmodel }"] ?= @params.pid
        memstore[][model].push object
        @res.send 201 object

    # CargoCulting, refactor later
    @get '/:appname/collections/:pmodel/:pid/:model/:id': ->
        {id, model} = @params
        model = singularize model
        res = select memmeta, memstore, model, filter: -> it._id is id
        return @res.send 404 {error: "No such ID"} unless res.length
        @res.send 200 res.0

    # CargoCulting, refactor later
    @put '/:appname/collections/:pmodel/:pid/:model/:id': ->
        model = singularize @params.model
        object = findOne model, @params.id
        object <<< @body
        @res.send 200 object

    # CargoCulting, refactor later
    @del '/:appname/collections/:pmodel/:pid/:model/:id': ->
        {pid} = @params
        model = singularize @params.model
        memstore[model] = memstore[model].filter -> it._id isnt id
        @res.send 201 null
