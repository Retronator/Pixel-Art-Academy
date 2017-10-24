AE = Artificial.Everywhere
AM = Artificial.Mummification
RS = Retronator.Store

Meteor.methods
  'Retronator.Store.Transaction.insertClaimedItem': (keyCode, claimEmail) ->
    console.log "claiming item", keyCode, claimEmail

    check keyCode, Match.DocumentId
    check claimEmail, Match.OptionalOrNull String

    userId = Meteor.userId()
    throw new AE.ArgumentNullException 'Claim email must be entered if the user is not logged in.' unless userId or claimEmail

    # Make sure this key code wasn't used yet.
    claimedTransaction = RS.Transaction.documents.findOne 'items.receivedGift.keyCode': keyCode

    throw new AE.ArgumentException 'Key code was already claimed.' if claimedTransaction

    # Find the transaction where this key code was generated.
    giftingTransaction = RS.Transaction.documents.findOne 'items.givenGift.keyCode': keyCode

    throw new AE.ArgumentException 'Key code was not found.' unless giftingTransaction?.items?

    # Search for the item with this key code.
    for purchasedItem in giftingTransaction.items when purchasedItem.givenGift?.keyCode is keyCode
      giftedItem = purchasedItem

    throw new AE.ArgumentException 'Gifted item was not found.' unless giftedItem

    # We have all the information needed, so create the transaction.
    transaction =
      time: new Date()
      items: [
        item:
          _id: giftedItem.item._id
        receivedGift:
          keyCode: keyCode
          transaction:
            _id: giftingTransaction._id
      ]

    if userId
      # This is a claim by a logged-in user, so simply record the id into the transaction.
      transaction.user =
        _id: userId

    else
      # The user is not logged in, so we expect to have the email ready.
      transaction.email = claimEmail

    # Insert the document for this transaction.
    claimTransactionId = RS.Transaction.documents.insert transaction

    # Update the gifting transaction. Find which item index we're updating.
    itemIndex = giftingTransaction.items.indexOf giftedItem

    RS.Transaction.documents.update giftingTransaction._id,
      $set:
        "items.#{itemIndex}.givenGift.transaction.id": claimTransactionId
