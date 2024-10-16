RA = Retronator.Accounts
RS = Retronator.Store

# Override the user class with extra store functionality.
class RA.User extends RA.User
  # profile: a custom object, writable by default by the client
  #   showSupporterName: boolean whether to show username in public displays
  #   supporterMessage: supporter message to show in public displays
  # supporterName: auto-generated supporter name
  # supportAmount: trigger-generated sum of all payments
  # store:
  #   balance: the sum of all payments minus sum of all purchases
  #   credit: positive part of balance
  # items: trigger-generated array of items owned by this user
  #   _id
  #   catalogKey
  @Meta
    name: @id()
    replaceParent: true
    collection: Meteor.users
    fields: (fields) =>
      _.extend fields,
        supporterName: Document.GeneratedField 'self', ['profile'], (user) ->
          supporterName = if user.profile?.showSupporterName then user.profile?.name else null
          [user._id, supporterName]

        items: [Document.ReferenceField RS.Item, ['catalogKey']]

      fields

    triggers: (triggers) =>
      _.extend triggers,
        # Transactions for a user can update when a new registered email is added or a twitter account is linked.
        transactionsUpdated: Document.Trigger ['registered_emails', 'twitterScreenName', 'patreonId'], (user, oldUser) ->
          console.log "User update detected!", user?.debugName or user?._id or oldUser?.debugName or oldUser?._id
          user?.onTransactionsUpdated()

      triggers

  # Subscriptions
  
  @topSupporters: 'Retronator.Accounts.User.topSupporters'
  @topSupportersCurrentUser: 'Retronator.Accounts.User.topSupportersCurrentUser'
  @supportAmountForCurrentUser: 'Retronator.Accounts.User.supportAmountForCurrentUser'
  @storeDataForCurrentUser: 'Retronator.Accounts.User.storeDataForCurrentUser'
  
  # Methods
  
  @getSupportersWithNames: @method 'getSupportersWithNames'

  authorizedPaymentsAmount: ->
    # Authorized payments amount is the sum of all payments that were only authorized.
    transactions = RS.Transaction.getValidTransactionsForUser @

    authorizedPaymentsAmount =
      total: 0

    for transaction in transactions when transaction.payments
      for payment in transaction.payments when payment.authorizedOnly
        authorizedPaymentsAmount[payment.type] ?= 0
        authorizedPaymentsAmount[payment.type] += payment.amount
        authorizedPaymentsAmount.total += payment.amount

    authorizedPaymentsAmount

  hasItem: (catalogKey) ->
    return true if _.find @items, (item) ->
      item.catalogKey is catalogKey

    false

  onTransactionsUpdated: ->
    console.log "Updating store-related fields for user", @displayName or @_id
    @generateItemsArray()
    @generateSupportAmount()
    @generateStoreData()

  generateItemsArray: ->
    # Start by constructing an array of all item Ids.
    itemIds = []
    transactions = RS.Transaction.getValidTransactionsForUser @

    # Add the items from each transaction except those given away as gifts.
    for transaction in transactions when transaction.items
      for transactionItem in transaction.items when not transactionItem.givenGift
        itemIds = _.union itemIds, RS.Item.getAllIncludedItemIds transactionItem.item

    # Create an array of item objects.
    items = _.map itemIds, (id) -> {_id: id}

    @constructor.documents.update @_id,
      $set:
        items: items

  generateSupportAmount: ->
    # Support amount is the sum of all payments.
    transactions = RS.Transaction.getValidTransactionsForUser @

    supportAmount = 0

    for transaction in transactions when transaction.payments
      supportAmount += payment.amount for payment in transaction.payments

    @constructor.documents.update @_id,
      $set:
        supportAmount: supportAmount

  generateStoreData: ->
    # Store balance is the sum of all payments minus sum of all purchases.
    transactions = RS.Transaction.getValidTransactionsForUser @

    balance = 0

    for transaction in transactions
      if transaction.payments
        balance += payment.amount for payment in transaction.payments when not payment.authorizedOnly

      if transaction.items
        balance -= transactionItem.price for transactionItem in transaction.items when transactionItem.price

      balance -= transaction.tip.amount if transaction.tip

    # Credit is any positive balance that the user can spend towards new purchases.
    credit = Math.max 0, balance

    @constructor.documents.update @_id,
      $set:
        store:
          balance: balance
          credit: credit
