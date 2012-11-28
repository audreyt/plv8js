#!/usr/bin/env lsc
{List, Task} = require './model'

ProtoList = do
    tasksAddedAtStart: $from: \Task, $query: CreatedAt: $: \CreatedAt
    tasksAddedAtLater: $from: \Task, $query: CreatedAt: $gt: $: \CreatedAt
    completeTasks: $from: \Task, $query: { +Complete }
    incompleteTasks: $from: \Task: $query: { -Complete }
    isFinalized: $: CreatedAt: $gt: $ago: 18hr * 3600s * 1000ms

l = new List <<< ProtoList
t = new Task
C = Collections = { List: [l], Task: [t] }

console.log select C.List

function select => it.map -> { [k, run.call it, v] for k, v of it }

function run ({$query, $}:it) => switch
    | $query? => '$q'
    | $? => expr.call it, $
    | _ => it

function expr => switch typeof it
    | <[ string number ]> => @[it]
    | \object =>
        # Implicit AND on all k,v
        for k, v of it
            return false unless test.call @, @[k], v
        true
    | _ => it

function test (val, expr) => switch typeof expr
    | <[ string number ]> => val is expr
    | \object => for op, v of expr => switch op
        | \$gt => throw "X"
        | _ => throw "Unknown operator: #k"
    | _ => throw "Unknown expression: #expr"

