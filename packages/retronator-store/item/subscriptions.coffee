RS = Retronator.Store

Meteor.publish RS.Item.all, ->
  RS.Item.documents.find()
