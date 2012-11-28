require! {uuid: 'uuid-pure'}


UUID = -> uuid.newId!

EmailAddress = -> 'foo@foo.com'
DateTime = -> new Date
Bool = -> false
Text = -> ''

List = ->
    _id: UUID!
    PreviousList: UUID!
    NextList: UUID!
    Owner: EmailAddress!
    CreatedAt: DateTime!
    LastCheckmarkAt: DateTime!
    CompletedAt: DateTime!
    FinalMailSent: Bool!

Task = ->
    _id: UUID!
    List: UUID!
    Complete: Bool!
    Description: Text!
    CreatedAt: DateTime!
    CompletedAt: DateTime!

module.exports = {List, Task}
