require! { uuid: \uuid-v4 }

ProtoExample =
    UUID: -> uuid!
    EmailAddress: -> 'foo@foo.com'
    DateTime: -> new Date
    Bool: -> false
    Text: -> ''
    Ref: -> null


class List
    -> @ <<< let @ = ProtoExample
        _id: @UUID!
        _List$Previous: @Ref!
        _List$Next: @Ref!
        Owner: @EmailAddress!
        CreatedAt: @DateTime!
        LastCheckmarkAt: @DateTime!
        CompletedAt: @DateTime!
        FinalMailSent: @Bool!

class Task
    -> @ <<< let @ = ProtoExample
        _id: @UUID!
        _List: @Ref!
        Complete: @Bool!
        Description: @Text!
        CreatedAt: @DateTime!
        CompletedAt: @DateTime!
    class @Create
        (args) -> @ <<< args

module.exports = {List, Task}
