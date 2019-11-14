AE = Artificial.Everywhere
RA = Retronator.Accounts
RS = Retronator.Store

RS.Pages.Admin.Transactions.giveItem.method (userId, email, twitter, itemCatalogKey) ->
  userId = null unless userId?.length
  check userId, Match.OptionalOrNull Match.DocumentId
  check email, Match.OptionalOrNull String
  check twitter, Match.OptionalOrNull String
  check itemCatalogKey, String

  throw new AE.ArgumentNullException "User ID or email or Twitter handle must be provided." unless userId or email or twitter

  RA.authorizeAdmin()

  item = RS.Item.documents.findOne catalogKey: itemCatalogKey

  throw new AE.ArgumentException "Item with catalog key #{itemCatalogKey} does not exist." unless item

  transaction =
    time: new Date()
    items: [
      item:
        _id: item._id
    ]

  transaction.user = _id: userId if userId
  transaction.email = email if email
  transaction.twitter = twitter if twitter

  RS.Transaction.documents.insert transaction

  console.log "Successfully given", itemCatalogKey, "to", userId or email or twitter, transaction
