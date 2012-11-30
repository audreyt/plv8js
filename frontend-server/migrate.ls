{USER} = process.env
{STRING, TEXT, DATE, BOOLEAN, INTEGER}:Sequelize = require \sequelize
sql = new Sequelize USER, USER, null, dialect: 'postgres', host: \127.0.0.1, port: 5432

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

l <- List.create { Owner: \foo@bar.com } .success
t <- Task.create { Description: \foo } .success

<- l.setTasks [t] .success

console.log l
console.log t
