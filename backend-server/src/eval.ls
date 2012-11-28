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

function select (db, table, { filter, query, count, fields, firstOnly, sort, skip, limit }={})
    rows = db[table]
    rows .=filter filter if filter
    rows .=filter(-> cond.call it, query) if query
    rows .=map ->
        $ := it
        { [name, run.call(
            it, db, table, field
        ) ] for name, field of it }
    switch
    | count     => { count: rows.length }
    | firstOnly => rows.0
    | fields    => throw "Not implemented: f"
    | sort      => throw "Not implemented: sort"
    | skip      => rows[skip til skip+limit]
    | limit     => rows[til limit]
    | _         => rows

function run (db, table, field) =>
    {$query, $from, $and, $} = field ? {}
    switch
    | $from? => select db, $from, filter: ~>
        ref = it["_#table"]
        switch
        | ref? and ref isnt @_id    => false
        | $query?                   => cond.call it, $query
        | _                         => true
    | $? => cond.call @, $
    | $and? =>
        for clause in $and
            return false unless run.call @, db, table, clause
        return true
    | _ => field

function cond => switch typeof it
    | <[ string number ]> => @[it]
    | \object =>
        # Implicit AND on all k,v
        for k, v of it
            console.log "Testing #k against #v"
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
