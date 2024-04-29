AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mummification
RS = Retronator.Store

class RS.Item.Key extends AM.Document
  @id: -> 'Retronator.Store.Item.Key'
  # code: string value for this key instance
  # item: which item this key corresponds to
  #   _id
  #   catalogKey
  # transaction: which transaction claimed this key, reverse of RS.Transaction.keys
  #   ownerDisplayName
  @Meta
    name: @id()
    fields: =>
      item: Document.ReferenceField RS.Item, ['catalogKey']
      
  @retrieveForItem: @method 'retrieveForItem'
