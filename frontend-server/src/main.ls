require! { pg, async, uuid: \uuid-v4 }
const { USER } = process.env
const pgConString = "tcp://#USER@localhost/#USER"
const { modelmeta } = require \./model

models = {List, Task} = (<~ require \./model .initmodels)
@include = ->
    memmeta ?= modelmeta
    pgClient = setupDatabase!

    @use \bodyParser, @app.router, @express.static __dirname + "/../_public"
    @get '/roundtrip': ->
        res <~ sendRequestToPg pgClient, @req
        serveResponseFromPg.call @, res

    for verb in <[get put post del]> => let orig = @[verb]
        @[verb] = ->
            return orig.call @, ... unless typeof it is \object
            orig.call @, { ["/databases#k", v] for k, v of it }
            orig.call @, { ["/db#k", v] for k, v of it }

    appname = 'Today'


    findWithModel = (model, queries, raw, cb) ->
        m = models[model] or throw 'undefined model'
        m.findAll do
            where: queries
            attributes: (m.userDefinedAttributes ? []) +++ Object.keys m.rawAttributes
        .success -> cb if raw => it else it.map ->
            row = it.selectedValues
            for col, val of row
                row[col] = JSON.parse val if /^\[/.test(val)
            return row

    findOneWithModel = (model, queries, raw, cb) ->
        findWithModel model, queries, raw, ->
            | it.length == 0 => cb null
            else             => cb it.0

    @get '': ->
        @res.send 200 [appname]

    @get '/:appname': ->
        @res.send 200 { collections: [k for k of models] }

    @get '/:appname/collections': ->
        @res.send 200 [k for k of models]

    @post '/:appname/collections/:model': ->
        m = models[@params.model] ?= null
        # XXX: if this is a new model, need to sync db as well
        console.log @params.model, @body
        throw '....' unless m
        object <~ m.create {_id: uuid!} <<< @body .success
        @res.send 201 object

    @get '/:appname/collections/:model': ->
        res <~ findWithModel @params.model, null, no
        @res.send 200 res

    @get '/:appname/collections/:model/:id': ->
        object <~ findOneWithModel @params.model, {_id: @params.id}, no
        return @res.send 404 {error: "No such ID"} unless object?
        @res.send 200 object

    @get '/:appname/collections/:model/:id/:field': ->
        object <~ findOneWithModel @params.model, {_id: @params.id}, no
        return @res.send 404 {error: "No such ID"} unless object?
        @res.send 200 object[@params.field]

    @put '/:appname/collections/:model/:id': ->
        {model, id} = @params
        object <~ findOneWithModel model, {_id: id}, yes
        return @res.send 404 {error: "No such ID"} unless object?

        if @body.tasks
            pid = object._id
            sub-model = singularize \tasks
            res <~ findWithModel sub-model, { _List: pid }, \raw
            console.log res
            console.log res.destroy
            todo = []
            m = models[sub-model] ?= null
            for sub-body in @body.tasks => let attrs = {_id: uuid!, "_#model": pid} <<< sub-body
                todo.push (cb) -> m.create(attrs).success(cb)
            todo.push ~>
                delete @body.tasks
                object.updateAttributes @body
                @res.send 200 object
            console.log todo
            async.series todo
        else
            object.updateAttributes @body
            @res.send 200 object

    @del '/:appname/collections/:model/:id': ->
        object <~ findOneWithModel @params.model, {_id: @params.id}, yes
        return @res.send 404 {error: "No such ID"} unless object?
        <~ object.destroy!
        @res.send 201 null

    singularize = (x) -> "#x".replace(/ies$/ 'y').replace(/s$/, '').replace(/^./, -> it.toUpperCase!)

    # CargoCulting, refactor later
    @post '/:appname/collections/:pmodel/:pid/:model': ->
        model = singularize @params.model
        m = models[model] ?= null
        object <~ m.create {_id: uuid!, "_#{ @params.pmodel }": @params.pid} <<< @body .success
        @res.send 201 object

    # CargoCulting, refactor later
    @put '/:appname/collections/:pmodel/:pid/:model/:id': ->
        model = singularize @params.model
        object <~ findOneWithModel model, {_id: @params.id}, yes
        return @res.send 404 {error: "No such ID"} unless object?
        object.updateAttributes @body
        @res.send 200 object

    # CargoCulting, refactor later
    @get '/:appname/collections/:pmodel/:pid/:model/:id': ->
        model = singularize @params.model
        object <~ findOneWithModel model, {_id: @params.id}, no
        return @res.send 404 {error: "No such ID"} unless object?
        @res.send 200 object[@params.field]

    # CargoCulting, refactor later
    @del '/:appname/collections/:pmodel/:pid/:model/:id': ->
        model = singularize @params.model
        object <~ findOneWithModel \Task {_id: @params.id}, yes
        return @res.send 404 {error: "No such ID"} unless object?
        <~ object.destroy!
        @res.send 201 null

setupDatabase = ->
    restInsert = """
        CREATE OR REPLACE FUNCTION rest (req json) RETURNS json AS $$
            return (#{ rest })(req);
        $$ LANGUAGE plv8 IMMUTABLE STRICT;
    """
    console.log "Injecting REST wrapper into database: \n#restInsert"
    return with new pg.Client pgConString
        ..connect!
        ..query restInsert


simplifyRequest = ->
    JSON.stringify it{ method, url, query, params, headers, body }

sendRequestToPg = (client, req, cb) ->
    require! pg
    conString = "tcp://#USER@localhost/#USER"
    err, result <~ client.query 'SELECT rest($1) as res' [
        simplifyRequest req
    ]
    console.log result
    console.log err
    cb JSON.parse result.rows.0.res

serveResponseFromPg = ({ headers, type, statusCode, body }) ->
    with @response
        for k, v of headers => ..set k, v
        ..type type
        ..send statusCode, body

# This function is never run in the Express webserver context.
# It's stringified and injected into postgres during startup.
rest = ->
    req = JSON.parse it
    result = plv8.execute req.query.q if req.query.q?
    JSON.stringify do
        status-code: 200
        type: \application/json
        headers:
            'X-Server': 'PostgreSQL'
        body: { result, orig: req }
