RS = Retronator.Store

RS.Item.all.publish ->
  RS.Item.documents.find()
