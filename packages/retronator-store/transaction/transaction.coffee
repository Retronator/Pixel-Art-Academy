AM = Artificial.Mummification
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Transaction extends AM.Document
  @id: -> 'Retronator.Store.Transaction'
  # time: when the transaction was conducted
  # user: logged-in user that this transaction belongs to or null if the user was not logged in
  #   _id
  #   displayName
  #   supporterName
  # email: lowercase user email entered for this transaction if user was not logged in during payment
  # twitter: lowercase twitter handle for this transaction if it was given to a twitter user
  # patreon: patron ID if this is a pledge created over Patreon
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
  #   invalid
  #   storeCreditAmount
  # taxInfo: extra information for VAT and income tax reporting, when this is a taxable transaction
  #   country:
  #     billing: billing address country as provided by the user
  #     payment: country of payment method as provided by the payment provider
  #     access: country where the payment was made as determined from the IP address
  #   accessIp: IP address of the client accessing the system
  #   invoiceId: invoice ID, if this transaction includes any monetary payments
  #     year: the UTC year of the transaction time
  #     number: a sequential integer
  #   vatRate: VAT rate of the billing country in effect at the time of transaction
  #   amountEur:
  #     net: EUR value of the payment without VAT
  #     vat: EUR value of VAT collected
  #   usdToEurExchangeRate: the reference exchange rate used in conversions
  #   business: information of the buyer, if it's a business in the EU
  #     vatId: VAT ID of the buyer
  #     name: name of the business, reported from VIES
  #     address: address of the business, reported from VIES
  # supporterName: the public name to show for this transaction for logged-out users
  # tip:
  #   amount: how much money was tipped
  #   message: the public message to show for this transaction
  # totalValue: auto-generated value of the transaction
  # invalid: auto-generated boolean that voids this transaction
  @Meta
    name: @id()
    fields: =>
      user: @ReferenceField RA.User, ['displayName', 'supporterName'], false
      items: [
        item: @ReferenceField RS.Item, ['catalogKey'], false
        receivedGift:
          transaction: @ReferenceField 'self', ['ownerDisplayName'], false
        givenGift:
          transaction: @ReferenceField 'self', ['ownerDisplayName'], false
      ]
      payments: [@ReferenceField RS.Payment, ['type', 'amount', 'authorizedOnly', 'invalid', 'storeCreditAmount']]
      ownerDisplayName: @GeneratedField 'self', ['user', 'email', 'twitter'], (fields) ->
        displayName = fields.user?.displayName
        displayName ?= "@#{fields.twitter}" if fields.twitter
        displayName ?= fields.email or ''
        [fields._id, displayName]
      totalValue: @GeneratedField 'self', ['items', 'tip'], (fields) ->
        return [fields._id, 0] unless fields.items

        # The total value of a transaction is the sum of all items' prices and the tip.
        value = fields.tip?.amount or 0
        value += (transactionItem.price or 0) for transactionItem in fields.items
        [fields._id, value]
      invalid: @GeneratedField 'self', ['payments'], (fields) ->
        invalid = _.some fields.payments, 'invalid'
        [fields._id, invalid]
    triggers: =>
      transactionsUpdated: @Trigger ['user._id', 'twitter', 'email', 'invalid', 'items', 'totalValue'], (transaction, oldTransaction) =>
        console.log "transaction generate items triggered!", transaction?.email or transaction?.user?._id or oldTransaction?.email or oldTransaction?.user?._id
        # If the user of this transaction has changed, the old user
        # should lose an item so they need to be updated as well.
        @findUserForTransaction(oldTransaction)?.onTransactionsUpdated()

        # Update the user of this transaction.
        @findUserForTransaction(transaction)?.onTransactionsUpdated()

  # Subscriptions
  @topRecent: 'Retronator.Store.Transaction.topRecent'
  @messages: 'Retronator.Store.Transaction.messages'
  @forCurrentUser: 'Retronator.Store.Transaction.forCurrentUser'
  @forGivenGiftKeyCode: 'Retronator.Store.Transaction.forGivenGiftKeyCode'
  @forReceivedGiftKeyCode: 'Retronator.Store.Transaction.forReceivedGiftKeyCode'

  # Methods
  @insertStripePurchase: 'Retronator.Store.Transaction.insertStripePurchase'
  @getMessages: @method 'getMessages'
  
  # Errors
  @serverErrorAfterPurchase: 'server-error-after-purchase'
  
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

    RS.Transaction.documents.find query

  @getValidTransactionsForUser: (user) ->
    _.filter @findTransactionsForUser(user).fetch(), (transaction) -> not transaction.invalid
