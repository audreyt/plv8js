#!/usr/bin/env lsc
uuid = require \uuid-v4
{USER} = process.env
{STRING, TEXT, DATE, BOOLEAN, INTEGER}:Sequelize = require \sequelize
sql = new Sequelize USER, null, null, dialect: \postgres, port: 5432

@ <<< do
    UUID: -> type: STRING, isUUID: 4
    Ref: -> type: STRING, isUUID: 4
    EmailAddress: -> STRING
    DateTime: -> DATE
    Bool: -> BOOLEAN
    Text: -> TEXT

Task = sql.define \Task do
    _id: @UUID!
    _List: @Ref!
    Complete: @Bool!
    Description: @Text!
    CreatedAt: @DateTime!
    CompletedAt: @DateTime!

List = sql.define \List do
    _id: @UUID!
    _List$Previous: @Ref!
    _List$Next: @Ref!
    Owner: @EmailAddress!
    CreatedAt: @DateTime!
    LastCheckmarkAt: @DateTime!
    CompletedAt: @DateTime!
    FinalMailSent: @Bool!

#List.hasMany Task, { as: \tasks, foreignKey: \_List, -useJunctionTable }

<- new Sequelize.Utils.QueryChainer!
    .add List.drop!
    .add List.sync!
    .add Task.drop!
    .add Task.sync!
    .run-serially!
    .success

l <- List.create { _id: uuid!, Owner: \foo@bar.com, CreatedAt: 'now' } .success
t <- Task.create { _id: uuid!, _List: l._id, Description: \foo, CreatedAt: 'now', -Complete } .success

#<- l.setTasks [t] .success

modelmeta = do
    List: do
        tasks:              $from: \Task
        tasksAddedAtStart:  $from: \Task $query: CreatedAt: $: \CreatedAt
        tasksAddedAtLater:  $from: \Task $query: CreatedAt: $gt: $: \CreatedAt
        completeTasks:      $from: \Task $query: { +Complete }
        incompleteTasks:    $from: \Task $query: { -Complete }
        isFinalized:        $: CreatedAt: $gt: $ago: 18hr * 3600s * 1000ms

q = -> """
    '#{ "#it".replace /'/g "''" }'
"""
qq = -> """
    "#{ "#it".replace /"/g '""' }"
"""

walk = (model, meta) ->
    return [] unless meta?[model]
    for col, spec of meta[model]
        [compile(model, spec), col]

compile = (model, field) ->
    {$query, $from, $and, $} = field ? {}
    switch
    | $from? => """
        (SELECT COALESCE(ARRAY_TO_JSON(ARRAY_AGG(_)), '[]') FROM (SELECT * FROM #from-table
            WHERE #{ qq "_#model" } = #model-table."_id" AND #{
                switch
                | $query?                   => cond model, $query
                | _                         => true
            }
        ) AS _)
    """ where from-table = qq "#{$from}s", model-table = qq "#{model}s"
    | $? => cond model, $
    | _ => field

cond = (model, spec) -> switch typeof spec
    | \number => spec
    | \string => qq spec
    | \object =>
        # Implicit AND on all k,v
        [ test model, qq(k), v for k, v of spec ] * "AND"
    | _ => it

test = (model, key, expr) -> switch typeof expr
    | <[ number boolean ]> => "(#key = #expr)"
    | \string => "(#key = #{ q expr })"
    | \object => for op, ref of expr
        switch op
            | \$gt =>
                res = evaluate model, ref
                return "(#key > #res)"
            | \$ =>
                return "#key = #model-table.#{ qq ref }" where model-table = qq "#{model}s"
            | _ => throw "Unknown operator: #op"
    | \undefined => true

evaluate = (model, ref) -> switch typeof ref
    | <[ number boolean ]> => "#ref"
    | \string => q #ref
    | \object => for op, v of ref => switch op
        | \$ => "#model-table.#{ qq v }" where model-table = qq "#{model}s"
        | \$ago => "'now'::timestamptz - #{ q "#v ms" }::interval"
        | _ => continue

ls <- List.findAll(
    attributes: walk \List modelmeta
).success

console.log ls.0.selectedValues
