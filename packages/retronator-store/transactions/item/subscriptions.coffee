RS = Retronator.Store

Meteor.publish RS.Transactions.Item.all, ->
  RS.Transactions.Item.documents.find()
