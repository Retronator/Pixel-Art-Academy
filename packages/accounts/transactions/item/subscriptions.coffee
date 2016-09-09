RA = Retronator.Accounts

Meteor.publish 'Retronator.Accounts.Transactions.Item.all', ->
  RA.Transactions.Item.documents.find()
