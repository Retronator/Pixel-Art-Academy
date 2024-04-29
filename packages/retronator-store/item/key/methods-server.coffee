AE = Artificial.Everywhere
AT = Artificial.Telepathy
RA = Retronator.Accounts
RS = Retronator.Store

RS.Item.Key.retrieveForItem.method (itemId) ->
  check itemId, Match.DocumentId
  
  user = Retronator.user()
  throw new AE.UnauthorizedException "Only users can retrieve item keys." unless user
  
  item = RS.Item.documents.findOne itemId
  throw new AE.ArgumentException "Item key requested for an invalid item ID." unless item
  
  console.log "User", user.displayName, "is retrieving a key for", item.catalogKey, "…"
  
  # See if this user already has a transaction with a key claim for this item.
  transactions = RS.Transaction.getValidTransactionsForUser @
  
  claimTransaction = _.find transactions, (transaction) -> _.find transaction.itemKeys, (itemKey) -> itemKey.item._id is item._id
  
  if claimTransaction
    console.log "Retrieved from existing claim."
    
    itemKey = _.find claimTransaction.itemKeys, (itemKey) -> itemKey.item._id is item._id
    
  else
    console.log "Making a new claim."
    
    # Find an item key that doesn't have a transaction associated with yet.
    itemKey = RS.Item.Key.documents.findOne
      'item._id': item._id
      transaction: $exists: false
      
    unless itemKey
      adminEmail = new AT.EmailComposer
      adminEmail.addParagraph "Item keys for #{item.catalogKey} have run out!"
      adminEmail.addParagraph "This happened to user #{user._id}."
      adminEmail.end()
      
      Email.send
        from: "hi@retronator.com"
        to: "hi@retronator.com"
        subject: "Insufficient item keys"
        text: adminEmail.text
        html: adminEmail.html
      
      throw new AE.LimitExceededException "I'm so sorry, the key is currently not available. Please email hi@retronator.com or reach out to me over social media and I'll fix it as soon as I can."
      
    # Create a transaction that claims this key.
    transaction =
      time: new Date()
      user:
        _id: user._id
      itemKeys: [
        _id: itemKey._id
      ]
    
    RS.Transaction.documents.insert transaction
    
  itemKey.code
