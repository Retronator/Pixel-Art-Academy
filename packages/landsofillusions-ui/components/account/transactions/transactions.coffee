AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class LOI.Components.Account.Transactions extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.Transactions'
  @url: -> 'purchases'
  @displayName: -> 'Purchases'

  @initialize()

  onCreated: ->
    super arguments...

    RA.User.twitterScreenNameForCurrentUser.subscribe @
    @subscribe Retronator.Accounts.User.supportAmountForCurrentUser
    @subscribe Retronator.Accounts.User.storeDataForCurrentUser
    RS.Item.all.subscribe @
    @subscribe Retronator.Store.Transaction.forCurrentUser
    Retronator.Store.Payment.forCurrentUser.subscribe @

    @showCreditInfo = new ReactiveField false
    @showAuthorizedPaymentsInfo = new ReactiveField false
    @showPatreonInfo = new ReactiveField false
    @currentTransaction = new ReactiveField null

  supportAmount: ->
    Retronator.user()?.supportAmount

  showSupporterName: ->
    Retronator.user()?.profile?.showSupporterName

  anonymousCheckboxAttributes: ->
    checked: true unless @showSupporterName()

  transactions: ->
    transactions = Retronator.Store.Transaction.findTransactionsForUser Retronator.user()
    return unless transactions

    transactions = transactions.fetch()

    # We only want to show transactions that were actual purchases (they have items).
    transactions = _.filter transactions, (transaction) => transaction.items

    # Remove all patreon transactions.
    transactions = _.filter transactions, (transaction) =>
      not _.find transaction.payments, (payment) -> payment.type is RS.Payment.Types.PatreonPledge

    # Refresh all items to get their names.
    for transaction in transactions when transaction.items
      for item in transaction.items
        item.item.refresh()

    _.sortBy transactions, 'time'

  invalidClass: ->
    transactionOrPayment = @currentData()
    'invalid' if transactionOrPayment.invalid

  payment: ->
    embeddedPayment = @currentData()
    RS.Payment.documents.findOne embeddedPayment._id

  emptyLines: ->
    transactionsCount = @transactions()?.length or 0

    endingMessages = [
      @showCurrentPatreonPledge()
      @showPositiveBalance()
      @showAuthorizedOnly()
    ]

    # See how many ending messages we have, otherwise set it to one since we'll generate one (end listing).
    endingCount = Math.max 1, _.sumBy endingMessages, (messagePresent) -> if messagePresent then 1 else 0

    # If we don't have any transactions, the ending message is 5 lines long.
    endingCount += 5 unless transactionsCount

    linesCount = transactionsCount + endingCount

    # There should be at least one empty line and the total should be at least 5
    emptyLines = Math.max 1, 5 - linesCount

    # Make sure we have an odd number of lines.
    emptyLines++ if (linesCount + emptyLines) % 2 is 0

    # Return an array with an element for every empty line.
    '' for i in [0...emptyLines]

  showCurrentPatreonPledge: ->
    @authorizedPaymentsAmount()?.PatreonPledge

  showPositiveBalance: ->
    Retronator.user()?.store?.credit

  showAuthorizedOnly: ->
    @authorizedPaymentsAmount()?.StripePayment

  showEndListing: ->
    # Only show end listing if no other messages will be present.
    not _.some [
      @showCurrentPatreonPledge()
      @showPositiveBalance()
      @showAuthorizedOnly()
    ]

  dateText: ->
    transaction = @currentData()
    languagePreference = AB.languagePreference()

    transaction.time.toLocaleDateString languagePreference,
      day: 'numeric'
      month: 'numeric'
      year: 'numeric'

  authorizedOnlyClass: ->
    transaction = @currentData()

    'authorized-only' if _.find transaction.payments, (payment) => payment.authorizedOnly

  claimLink: ->
    item = @currentData()
    item.givenGift.keyCode

  paymentAmount: ->
    payment = @currentData()
    payment.amount or payment.storeCreditAmount

  authorizedPaymentsAmount: ->
    Retronator.user()?.authorizedPaymentsAmount()

  # Events

  events: ->
    super(arguments...).concat
      'change .anonymous-checkbox': @onChangeAnonymousCheckbox
      'click .load-credit-info': @onClickLoadCreditInfo
      'click .load-authorized-payments-info': @onClickLoadAuthorizedPaymentsInfo
      'click .load-patreon-info': @onClickLoadPatreonInfo
      'click .info-note': @onClickInfoNote
      'click .load-transaction': @onClickLoadTransaction
      'click': @onClick

  onChangeAnonymousCheckbox: (event) ->
    Meteor.call "Retronator.Accounts.User.setShowSupporterName", not event.target.checked

  onClickLoadCreditInfo: (event) ->
    @showCreditInfo true
    @showAuthorizedPaymentsInfo false
    @currentTransaction null
    @showPatreonInfo false

  onClickLoadPatreonInfo: (event) ->
    @showPatreonInfo true
    @showCreditInfo false
    @showAuthorizedPaymentsInfo false
    @currentTransaction null

  onClickLoadAuthorizedPaymentsInfo: (event) ->
    @showCreditInfo false
    @showAuthorizedPaymentsInfo true
    @currentTransaction null
    @showPatreonInfo false

  onClickInfoNote: (event) ->
    @showCreditInfo false
    @showAuthorizedPaymentsInfo false
    @showPatreonInfo false

  onClickLoadTransaction: (event) ->
    transaction = @currentData()
    @currentTransaction transaction
    
    @showCreditInfo false
    @showAuthorizedPaymentsInfo false
    @showPatreonInfo false

  onClick: (event) ->
    return if $(event.target).closest('.load-transaction').length

    @currentTransaction null

  # Components

  class @SupporterMessage extends AM.DataInputComponent
    @register 'LandsOfIllusions.Components.Account.Transactions.SupporterMessage'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.TextArea

    load: ->
      user = RA.User.documents.findOne Meteor.userId(),
        fields:
          'profile.supporterMessage': 1

      user?.profile?.supporterMessage

    save: (value) ->
      Meteor.call "Retronator.Accounts.User.setSupporterMessage", value

    placeholder: ->
      @translate('Add a message to supporters list').text
