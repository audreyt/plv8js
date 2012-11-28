#!/usr/bin/env lsc
{List, Task} = require './model'

ProtoList = do
    tasks:              $from: \Task
    tasksAddedAtStart:  $from: \Task $query: CreatedAt: $: \CreatedAt
    tasksAddedAtLater:  $from: \Task $query: CreatedAt: $gt: $: \CreatedAt
    completeTasks:      $from: \Task $query: { +Complete }
    incompleteTasks:    $from: \Task $query: { -Complete }
    isFinalized:        $: CreatedAt: $gt: $ago: 18hr * 3600s * 1000ms

$ = null

function select (db, table, filter)
    rows = db[table]
    rows .=filter filter if filter
    rows.map ->
        $ := it
        { [name, run.call(it, db, table, field) ] for name, field of it }

function run (db, table, field) =>
    {$query, $from, $} = field ? {}
    switch
    | $from? => select db, $from, ~>
        ref = it["_#table"]
        return false if ref? and ref isnt @_id
        return false if $query? and not cond.call it, $query
        return true
    | $? => cond.call @, $
    | _ => field

function cond => switch typeof it
    | <[ string number ]> => @[it]
    | \object =>
        # Implicit AND on all k,v
        for k, v of it
            return false unless test.call @, @[k], v
        true
    | _ => it

function test (val, expr) => switch typeof expr
    | <[ string number boolean ]> => val is expr
    | \object => for op, ref of expr
        switch op
            | \$gt =>
                res = evaluate.call @, ref
                return val > res
            | \$ =>
                return val is $[ref]
            | _ => throw "Unknown operator: #op"
    | \undefined => yes
    | _ => throw "Unknown expression: #expr"


function evaluate => switch typeof it
    | <[ string number ]> => it
    | \object => for op, v of it => switch op
        | \$ago => new Date(Number(new Date) - res)
            where res = evaluate.call @, v
        | _ => continue

module.exports = { select, ProtoList }
