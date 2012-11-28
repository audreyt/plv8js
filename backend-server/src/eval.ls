#!/usr/bin/env lsc
{List, Task} = require './model'

$ = null

function select (meta, db, table, { filter, query, count, fields, firstOnly, sort, skip, limit }={})
    rows = db[table]
    proto = meta[table] ? {}
    console.log table, proto
    rows .=filter filter if filter
    rows .=filter(-> cond.call it, query) if query
    rows .=map ->
        it <<< proto
        console.log it
        $ := it
        { [name, run.call(
            $, meta, db, table, it[name], console.log name, it[name]
        ) ] for name of $ }
    switch
    | count     => { count: rows.length }
    | firstOnly => rows.0
    | fields    => throw "Not implemented: f"
    | sort      => throw "Not implemented: sort"
    | skip      => rows[skip til skip+limit]
    | limit     => rows[til limit]
    | _         => rows

function run (meta, db, table, field) =>
    {$query, $from, $and, $} = field ? {}
    switch
    | $from? => select meta, db, $from, filter: ~>
        ref = it["_#table"]
        switch
        | ref? and ref isnt @_id    => false
        | $query?                   => cond.call it, $query
        | _                         => true
    | $? => cond.call @, $
    | $and? =>
        for clause in $and
            return false unless run.call @, meta, db, table, clause
        return true
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

module.exports = { select }
