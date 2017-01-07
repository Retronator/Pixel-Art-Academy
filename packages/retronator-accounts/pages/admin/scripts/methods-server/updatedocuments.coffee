RA = Retronator.Accounts

Meteor.methods
  'Retronator.Accounts.UpdateDocuments': ->
    RA.authorizeAdmin()

    Document.updateAll()
