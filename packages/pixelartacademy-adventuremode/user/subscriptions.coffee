RA = Retronator.Accounts

RA.User.charactersFieldForCurrentUser.publish ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      'characters': true
