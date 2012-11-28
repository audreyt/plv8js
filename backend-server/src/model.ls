require! {uuid: 'uuid-pure'}

ProtoExample =
    UUID: -> uuid.newId!
    EmailAddress: -> 'foo@foo.com'
    DateTime: -> new Date
    Bool: -> false
    Text: -> ''


class List implements ProtoExample
    -> @ <<< do
        _id: @UUID!
        PreviousList: @UUID!
        NextList: @UUID!
        Owner: @EmailAddress!
        CreatedAt: @DateTime!
        LastCheckmarkAt: @DateTime!
        CompletedAt: @DateTime!
        FinalMailSent: @Bool!

class Task implements ProtoExample
    -> @ <<< do
        _id: @UUID!
        List: @UUID!
        Complete: @Bool!
        Description: @Text!
        CreatedAt: @DateTime!
        CompletedAt: @DateTime!

module.exports = {List, Task}
