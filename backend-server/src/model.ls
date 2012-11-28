require! {uuid: 'uuid-pure'}

ProtoExample =
    UUID: -> uuid.newId!
    EmailAddress: -> 'foo@foo.com'
    DateTime: -> new Date
    Bool: -> false
    Text: -> ''


class List
    -> @ <<< let @ = ProtoExample
        _id: @UUID!
        _List$Previous: @UUID!
        _List$Next: @UUID!
        Owner: @EmailAddress!
        CreatedAt: @DateTime!
        LastCheckmarkAt: @DateTime!
        CompletedAt: @DateTime!
        FinalMailSent: @Bool!

class Task
    -> @ <<< let @ = ProtoExample
        _id: @UUID!
        _List: @UUID!
        Complete: @Bool!
        Description: @Text!
        CreatedAt: @DateTime!
        CompletedAt: @DateTime!
    class @Create
        (args) -> @ <<< args

module.exports = {List, Task}
