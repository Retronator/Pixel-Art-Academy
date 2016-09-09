AB = Artificial.Babel
RA = Retronator.Accounts

class RetronatorAccountsUser extends Document
  # username: user's username
  # emails: list of emails used to login with a password
  #   address: email address
  #   verified: is email address verified?
  # registered_emails: list of all emails across all login services
  #   address: email address
  #   verified: is email address verified?
  # createdAt: time when user joined
  # profile: a custom object, writable by default by the client
  #   name: the name the user wants to privately display in the system
  #   supporterName: the name the user wants to publicly display as a supporter
  #   showSupporterName: boolean whether to use the supporter name or not
  # displayName: auto-generated display name
  # supporterName: auto-generated supporter name
  # supportAmount: generated sum of all payments
  # services: array of authentication/linked service and their login tokens
  # loginServices: auto-generated array of service names that were added to services and can be used to login
  # items: generated array of items owned by this user
  #   _id
  #   catalogKey
  # landsofillusions: data related to Lands of Illusions
  #   characters: list of characters the user has created, reverse of character.user
  #     _id
  #     name
  @Meta
    name: 'RetronatorAccountsUser'
    collection: Meteor.users
    fields: =>
      displayName: @GeneratedField 'self', ['username', 'profile', 'registered_emails'], (user) ->
        displayName = user.profile?.name or user.username or user.registered_emails?[0]?.address or ''
        [user._id, displayName]

      supporterName: @GeneratedField 'self', ['profile'], (user) ->
        supporterName = if user.profile?.showSupporterName then user.profile?.supporterName else null
        [user._id, supporterName]

      loginServices: [@GeneratedField 'self', ['services'], (user) ->
        availableServices = ['password', 'facebook', 'twitter', 'google']
        enabledServices = _.intersection _.keys(user.services), availableServices
        [user._id, enabledServices]
      ]

      items: [@ReferenceField RA.Transactions.Item, ['catalogKey']]

    triggers: =>
      # Transactions for a user can update when a new registered email is added or a twitter account is linked.
      transactionsUpdated: @Trigger ['registered_emails', 'services.twitter.screenName'], (user, oldUser) ->
        user?.onTransactionsUpdated()

  storeBalance: ->
    # Store balance is the sum of all payments minus sum of all purchases.
    transactions = RA.Transactions.Transaction.findTransactionsForUser(@).fetch()

    balance = 0

    for transaction in transactions
      if transaction.payments
        balance += payment.amount for payment in transaction.payments when not payment.authorizedOnly

      balance -= transactionItem.price for transactionItem in transaction.items when transactionItem.price
      balance -= transaction.tip.amount if transaction.tip

    balance

  storeCredit: ->
    # Credit is any positive balance that the user can spend towards new purchases.
    Math.max 0, @storeBalance()

  authorizedPaymentsAmount: ->
    # Authorized payments amount is the sum of all payments that were only authorized.
    transactions = RA.Transactions.Transaction.findTransactionsForUser(@).fetch()

    authorizedPaymentsAmount = 0

    for transaction in transactions when transaction.payments
      authorizedPaymentsAmount += payment.amount for payment in transaction.payments when payment.authorizedOnly

    authorizedPaymentsAmount

  hasItem: (catalogKey) ->
    return true if _.find @items, (item) ->
      item.catalogKey is catalogKey

    false
    
  onTransactionsUpdated: ->
    @generateItemsArray()
    @generateSupportAmount()

  generateItemsArray: ->
    # Start by constructing an array of all item Ids.
    itemIds = []
    transactions = RA.Transactions.Transaction.findTransactionsForUser(@).fetch()

    # Helper function that recursively adds items.
    addItem = (item) =>
      item = RA.Transactions.Item.documents.findOne item._id

      # Add the item to the ids.
      itemIds = _.union itemIds, [item._id]

      if item.items
        # This is a bundle. Add all items of the bundle as well.
        addItem bundleItem for bundleItem in item.items

    # Add the items from each transaction except those given away as gifts.
    for transaction in transactions
      for transactionItem in transaction.items
        addItem transactionItem.item unless transactionItem.givenGift

    # Create an array of item objects.
    items = _.map itemIds, (id) -> {_id: id}

    @constructor.documents.update @_id,
      $set:
        items: items

  generateSupportAmount: ->
    # Support amount is the sum of all payments.
    transactions = RA.Transactions.Transaction.findTransactionsForUser(@).fetch()

    supportAmount = 0

    for transaction in transactions when transaction.payments
      supportAmount += payment.amount for payment in transaction.payments

    @constructor.documents.update @_id,
      $set:
        supportAmount: supportAmount

if Meteor.isClient
  Meteor.startup ->
    RA.User._babelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'

RA.User = RetronatorAccountsUser
