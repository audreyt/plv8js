{USER} = process.env
{STRING, TEXT, DATE, BOOLEAN, INTEGER}:Sequelize = require \sequelize
sql = new Sequelize USER, null, null, dialect: \postgres, port: 5432

@ <<< do
    UUID: -> type: STRING, isUUID: 4
    Ref: -> INTEGER # type: STRING, isUUID: 4
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

List.hasMany Task, { as: \tasks, foreignKey: \_List, -useJunctionTable }

<- new Sequelize.Utils.QueryChainer!
    .add List.drop!
    .add List.sync!
    .add Task.drop!
    .add Task.sync!
    .run-serially!
    .success

l <- List.create { Owner: \foo@bar.com, CreatedAt: 'now' } .success
t <- Task.create { Description: \foo, CreatedAt: 'now', -Complete } .success

<- l.setTasks [t] .success

ls <- List.findAll(
    attributes: [
        * """
            (select COALESCE(ARRAY_TO_JSON(ARRAY_AGG(_)), '[]') FROM (SELECT * from "Tasks") AS _)
        """ \tasks
        * """
            (select COALESCE(ARRAY_TO_JSON(ARRAY_AGG(_)), '[]') FROM (SELECT * from "Tasks"
                WHERE "Tasks"."CreatedAt" = "Lists"."CreatedAt"
            ) AS _)
        """ \tasksAddedAtStart
        * """
            (select COALESCE(ARRAY_TO_JSON(ARRAY_AGG(_)), '[]') FROM (SELECT * from "Tasks"
                WHERE "Tasks"."CreatedAt" > "Lists"."CreatedAt"
            ) AS _)
        """ \tasksAddedAtLater
        * """
            (select COALESCE(ARRAY_TO_JSON(ARRAY_AGG(_)), '[]') FROM (SELECT * from "Tasks"
                WHERE "Tasks"."Complete"
            ) AS _)
        """ \completeTasks
        * """
            (select COALESCE(ARRAY_TO_JSON(ARRAY_AGG(_)), '[]') FROM (SELECT * from "Tasks"
                WHERE NOT "Tasks"."Complete"
            ) AS _)
        """ \incompleteTasks
        * """
            "CreatedAt" < 'now'::timestamptz - '#{
                18hr * 3600s * 1000ms
            }ms'::interval
        """ \isFinalized
    ] +++ Object.keys List.rawAttributes
).success

console.log ls.0.selectedValues
