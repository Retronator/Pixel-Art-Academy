RS = Retronator.Store

Meteor.publish 'Retronator.Store.Transactions.Item.all', ->
  RS.Transactions.Item.documents.find()
