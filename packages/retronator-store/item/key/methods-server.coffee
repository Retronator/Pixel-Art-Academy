AB = Artificial.Babel
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
  transactions = RS.Transaction.getValidTransactionsForUser user
  
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

RS.Item.Key.emailKeys.method (emailAddress) ->
  check emailAddress, String

  console.log "Retrieving keys for", emailAddress
  
  # Find transactions attached to the email. Note that we have to search for all transactions since the
  # claimable items might be part of bundled items and not appear directly in the transaction.
  transactions = RS.Transaction.documents.fetch
    email: emailAddress.toLowerCase()
    invalid: false

  # Add all transactions of the user associated with this email.
  user = Meteor.users.findOne
    registered_emails:
      $elemMatch:
        address: emailAddress
        verified: true
  
  transactions.push RS.Transaction.getValidTransactionsForUser(user)... if user
  
  # Find out which of the claimable items result from these transactions.
  claimableItems = RS.Item.documents.fetch isKey: true
  claimableItemIds = (item._id for item in claimableItems)
  
  ownedClaimableItemIds = []
  
  for transaction in transactions when transaction.items
    for transactionItem in transaction.items when not transactionItem.givenGift
      transactionItemIds = RS.Item.getAllIncludedItemIds transactionItem.item
      claimableTransactionItemIds = _.intersection transactionItemIds, claimableItemIds
      ownedClaimableItemIds = _.union ownedClaimableItemIds, claimableTransactionItemIds
  
  # Email the user with a key for each of the claimable items.
  userEmail = new AT.EmailComposer
  userEmail.addParagraph "Hi,"

  if ownedClaimableItemIds.length
    # Retrieve key codes and make any new claims.
    claimedItemKeys = []
    unavailable = false
    
    userEmail.addParagraph "Here are all the keys you are eligible for:"
    
    for itemId in ownedClaimableItemIds
      item = _.find claimableItems, (claimableItem) -> claimableItem._id is itemId
      item.name.refresh()
      
      claimTransaction = _.find transactions, (transaction) -> _.find transaction.itemKeys, (itemKey) -> itemKey.item._id is itemId
      
      if claimTransaction
        console.log "Retrieved #{item.catalogKey} from existing claim."
        
        itemKey = _.find claimTransaction.itemKeys, (itemKey) -> itemKey.item._id is item._id
      
      else
        console.log "Making a new claim for #{item.catalogKey}."
        
        # Find an item key that doesn't have a transaction associated with yet.
        itemKey = RS.Item.Key.documents.findOne
          'item._id': itemId
          transaction: $exists: false
        
        if itemKey
          claimedItemKeys.push
            _id: itemKey._id
          
        else
          adminEmail = new AT.EmailComposer
          adminEmail.addParagraph "Item keys for #{item.catalogKey} have run out!"
          adminEmail.addParagraph "This happened for email #{emailAddress}."
          adminEmail.end()
          
          Email.send
            from: "hi@retronator.com"
            to: "hi@retronator.com"
            subject: "Insufficient item keys"
            text: adminEmail.text
            html: adminEmail.html
        
      if itemKey
        userEmail.addParagraph "#{item.name.translate().text}: #{itemKey.code}"
        
      else
        unavailable = true
        userEmail.addParagraph "#{item.name.translate().text}: not available"
  
    if claimedItemKeys.length
      # Create a transaction that claims the keys.
      transaction =
        time: new Date()
        email: emailAddress
        itemKeys: claimedItemKeys
      
      RS.Transaction.documents.insert transaction
  
    if unavailable
      userEmail.addParagraph "Looks like some keys were not available at this time, I'm so sorry about that. I'll fix it as soon as I can and send you the keys."
      userEmail.addParagraph "Thank you for your patience,\n
                               Matej 'Retro' Jan // Retronator"

    else
      userEmail.addParagraph "Best,\n
                               Matej 'Retro' Jan // Retronator"

  else
    userEmail.addParagraph "Thank you for requesting to send you keys for Retronator products. Unfortunately, I can't find any purchases that would be eligible for keys with this email."
    userEmail.addParagraph "Reply to let me know which keys you were expecting to receive and I can look into it."
    userEmail.addParagraph "Thank you,\n
                             Matej 'Retro' Jan // Retronator"

  userEmail.end()
  
  Email.send
    from: "hi@retronator.com"
    to: emailAddress
    subject: "Retronator keys claim"
    text: userEmail.text
    html: userEmail.html
