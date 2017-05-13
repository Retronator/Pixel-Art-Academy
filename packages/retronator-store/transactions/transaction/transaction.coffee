AM = Artificial.Mummification
RA = Retronator.Accounts
RS = Retronator.Store

class RetronatorStoreTransactionsTransaction extends AM.Document
  # time: when the transaction was conducted
  # user: logged-in user that this transaction belongs to or null if the user was not logged in
  #   _id
  #   displayName
  #   supporterName
  # email: lowercase user email entered for this transaction if user was not logged in during payment
  # twitter: lowercase twitter handle for this transaction if it was given to a twitter user
  # ownerDisplayName: auto-generated name used to display who initiated this transaction
  # items: array of items received in this transaction
  #   item: the item document
  #     _id
  #     catalogKey
  #   price: price of the item at the time of the purchase, unless item was a received gifted
  #   receivedGift:
  #     keyCode: a unique key code with which this gifted item was claimed
  #     transaction: the transaction from which this gifted item comes
  #       _id
  #       ownerDisplayName
  #   givenGift:
  #     keyCode: a unique key code generated to represent this item
  #     transaction: the transaction where this gift was claimed
  #       _id
  #       ownerDisplayName
  # payments: array of payments used in this transaction
  #   _id
  #   type
  #   amount
  #   authorizedOnly
  #   storeCreditAmount
  # supporterName: the public name to show for this transaction for logged-out users
  # tip:
  #   amount: how much money was tipped
  #   message: the public message to show for this transaction
  # totalValue: auto-generated value of the transaction
  @Meta
    name: 'RetronatorStoreTransactionsTransaction'
    fields: =>
      user: @ReferenceField RA.User, ['displayName', 'supporterName'], false
      items: [
        item: @ReferenceField RS.Transactions.Item, ['catalogKey'], false
        receivedGift:
          transaction: @ReferenceField 'self', ['ownerDisplayName'], false
        givenGift:
          transaction: @ReferenceField 'self', ['ownerDisplayName'], false
      ]
      payments: [@ReferenceField RS.Transactions.Payment, ['type', 'amount', 'authorizedOnly', 'storeCreditAmount']]
      ownerDisplayName: @GeneratedField 'self', ['user', 'email', 'twitter'], (fields) ->
        displayName = fields.user?.displayName
        displayName ?= "@#{fields.twitter}" if fields.twitter
        displayName ?= fields.email or ''
        [fields._id, displayName]
      totalValue: @GeneratedField 'self', ['items', 'tip'], (fields) ->
        return unless fields.items

        # The total value of a transaction is the sum of all items' prices and the tip.
        value = fields.tip?.amount or 0
        value += (transactionItem.price or 0) for transactionItem in fields.items
        [fields._id, value]
    triggers: =>
      transactionsUpdated: @Trigger ['user._id', 'twitter', 'email'], (transaction, oldTransaction) =>
        console.log "transaction generate items triggered!", transaction, "old", oldTransaction
        # If the user of this transaction has changed, the old user
        # should lose an item so they need to be updated as well.
        @findUserForTransaction(oldTransaction)?.onTransactionsUpdated()

        # Update the user of this transaction.
        @findUserForTransaction(transaction)?.onTransactionsUpdated()

  # Subscriptions
  @topRecent: 'Retronator.Store.Transactions.Transaction.topRecent'
  @messages: 'Retronator.Store.Transactions.Transaction.messages'
  @forCurrentUser: 'Retronator.Store.Transactions.Transaction.forCurrentUser'
  @forGivenGiftKeyCode: 'Retronator.Store.Transactions.Transaction.forGivenGiftKeyCode'
  @forReceivedGiftKeyCode: 'Retronator.Store.Transactions.Transaction.forReceivedGiftKeyCode'

  # Methods
  @insertStripePurchase: 'Retronator.Store.Transactions.Transaction.insertStripePurchase'
  
  @findUserForTransaction: (transaction) ->
    return unless transaction

    # Find the user of this transaction if possible. First, see if it is set directly.
    return RA.User.documents.findOne transaction.user._id if transaction.user?._id

    # Try and find the user by email.
    if transaction.email
      return RA.User.documents.findOne
        registered_emails:
          address: transaction.email
          verified: true

    # Try and find the user by twitter.
    return RA.User.documents.findOne 'services.twitter.screenName': transaction.twitter if transaction.twitter

  findUserForTransaction: ->
    @constructor.findUserForTransaction @

  @findTransactionsForUser: (user) ->
    return unless user

    # Transactions can be matched to validated emails, user's id or twitter handle.
    verifiedEmails = []
    if user.registered_emails
      for email in user.registered_emails
        # We want to compare without case.
        verifiedEmails.push new RegExp email.address, 'i' if email.verified

    query = $or: [
      'user._id': user._id
    ]

    if verifiedEmails.length
      query.$or.push
        email:
          $in: verifiedEmails

    if user.services?.twitter?.screenName
      query.$or.push
        twitter: new RegExp user.services.twitter.screenName, 'i'

    RS.Transactions.Transaction.documents.find query
      
RS.Transactions.Transaction = RetronatorStoreTransactionsTransaction
