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

err, response, body <- request.put do
    uri: base + 'db/Today/collections/List'
    json: ProtoList
console.log body

err, response, ttt <- request.post do
    uri: base + 'db/Today/collections/Task'
    json: do
        Description: \newthing
console.log ttt

err, response, [task] <- request.get do
    uri: base + 'db/Today/collections/Task'
    json: true

err, response, body <- request.put do
    uri: base + 'db/Today/collections/Task/' + task._id
    json: { Description: \foo }
console.log body

