#!/usr/bin/env lsc
{List, Task} = require './model'
require! \request

ProtoList = do
    tasksAddedAtStart: $from: \Task, $query: CreatedAt: $: \CreatedAt
    tasksAddedAtLater: $from: \Task, $query: CreatedAt: $gt: $: \CreatedAt
    completeTasks: $from: \Task, $query: { +Complete }
    incompleteTasks: $from: \Task: $query: { -Complete }
    isFinalized: $: CreatedAt: $gt: $ago: 18hr * 3600s * 1000ms

base = 'http://localhost:8888/'

id = \md6u_TFmj0QK-0K-1SzG-P

err, response, body <- request.put do
    uri: base + 'database/Today/collections/Task/' + id
    json: Description: \fooobar
console.log body
#err, response, body <- request.put do
#    uri: base + 'database/Today/collections/List/_'
#    json: ProtoList
#console.log body

