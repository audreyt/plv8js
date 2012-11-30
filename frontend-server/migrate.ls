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

{walk, compile} = require \./lib/compile
ls <- List.findAll(
    attributes: walk \List modelmeta
).success

console.log ls.0.selectedValues
