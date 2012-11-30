{USER} = process.env
{STRING, TEXT, DATE, BOOLEAN}:Sequelize = require \sequelize
sql = new Sequelize USER, USER, null, dialect: 'postgres', host: \127.0.0.1, port: 5432

@ <<< do
    UUID: -> STRING
    Ref: -> STRING
    EmailAddress: -> STRING
    DateTime: -> DATE
    Bool: -> BOOLEAN
    Text: -> STRING

Task = sql.define \Task do
    _id: @UUID!
    _List: @Ref!
    Complete: @Bool!
    Description: @Text!
    CreatedAt: @DateTime!
    CompletedAt: @DateTime!
Task.sync!

List = sql.define \List do
    _id: @UUID!
    _List$Previous: @Ref!
    _List$Next: @Ref!
    Owner: @EmailAddress!
    CreatedAt: @DateTime!
    LastCheckmarkAt: @DateTime!
    CompletedAt: @DateTime!
    FinalMailSent: @Bool!
List.sync!
