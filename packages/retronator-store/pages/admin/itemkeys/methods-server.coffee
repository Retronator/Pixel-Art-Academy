RA = Retronator.Accounts
RS = Retronator.Store

###
  This method used to be able to import any kind of users, but has now been modified to only correctly update
  Kickstarter backers. It is to be removed as soon as the integrity of the converted backers data (into transactions)
  has been confirmed.
###

Meteor.methods
  'Retronator.Store.importItemKeys': (itemId, encodedData) ->
    check itemId, Match.DocumentId
    check encodedData, String

    RA.authorizeAdmin()

    unless Meteor.settings.dataUploadPassphrase
      console.error "You need to specify the data upload passphrase in the settings file and don't forget to run the server with the --settings flag pointing to it."
      throw new Meteor.Error 'invalid-operation', "Passphrase not specified."

    passphrase = Meteor.settings.dataUploadPassphrase

    textData = CryptoJS.AES.decrypt(encodedData, passphrase).toString(CryptoJS.enc.Latin1)

    throw new Meteor.Error 'unauthorized', "Invalid passphrase." unless 'HEADER' is textData.substring 0, 6

    # Strip the header.
    textData = textData.substring 6
    
    lines = textData.match /[^\r\n]+/g
    console.log "Importing", lines.length, "item keys …"

    # Create an item key for each line.
    keysCount = 0
    for code in lines
      existing = RS.Item.Key.documents.findOne
        code: code
        'item._id': itemId
        
      continue if existing
      
      RS.Item.Key.documents.insert
        code: code
        item:
          _id: itemId
      
      keysCount++

    console.log "Successfully imported", keysCount, "item keys."
    
  'Retronator.Store.itemKeysOverview': ->
    RA.authorizeAdmin()
    
    itemKeysOverview = []
    
    items = RS.Item.documents.fetch()
    
    for item in items
      itemKeysCursor = RS.Item.Key.documents.find
        'item._id': item._id
        
      if totalCount = itemKeysCursor.count()
        claimedCount = RS.Item.Key.documents.find(
          'item._id': item._id
          transaction: $exists: true
        ).count()
        
        availableCount = RS.Item.Key.documents.find(
          'item._id': item._id
          transaction: $exists: false
        ).count()
        
        console.warn "Claimed and available counts for #{item.catalogKey} don't add up. #{claimedCount} + #{availableCount} != #{totalCount}" unless claimedCount + availableCount is totalCount
      
        itemKeysOverview.push {catalogKey: item.catalogKey, totalCount, claimedCount, availableCount}
    
    itemKeysOverview
