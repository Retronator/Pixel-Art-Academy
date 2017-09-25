AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts

class LOI.Components.Account.Transactions extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.Transactions'
  @url: -> 'transactions'
  @displayName: -> 'Transactions'

  @initialize()

  onCreated: ->
    super

    @subscribe Retronator.Accounts.User.supportAmountForCurrentUser
    @subscribe Retronator.Accounts.User.storeDataForCurrentUser
    @subscribe Retronator.Store.Transactions.Item.all
    @subscribe Retronator.Store.Transactions.Transaction.forCurrentUser

    @showCreditInfo = new ReactiveField false
    @showAuthorizedPaymentsInfo = new ReactiveField false
    @currentTransaction = new ReactiveField null

  supportAmount: ->
    Retronator.user()?.supportAmount

  showSupporterName: ->
    Retronator.user()?.profile?.showSupporterName

  anonymousCheckboxAttributes: ->
    checked: true unless @showSupporterName()

  transactions: ->
    transactions = Retronator.Store.Transactions.Transaction.findTransactionsForUser Retronator.user()
    return unless transactions

    transactions = transactions.fetch()

    # Refresh all items to get their names.
    for transaction in transactions
      for item in transaction.items
        item.item.refresh()

    _.sortBy transactions, 'time'

  emptyLines: ->
    transactionsCount = @transactions()?.length

    if transactionsCount
      maximumRows = Math.max 3, transactionsCount

    else
      maximumRows = 2

    maximumRows++ if maximumRows % 2 is 1

    # Return an array with enough elements to pad the transactions list to 5 rows.
    '' for i in [transactionsCount...maximumRows]

  dateText: ->
    transaction = @currentData()
    languagePreference = AB.userLanguagePreference()

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
    super.concat
      'change .anonymous-checkbox': @onChangeAnonymousCheckbox
      'click .load-credit-info': @onClickLoadCreditInfo
      'click .load-authorized-payments-info': @onClickLoadAuthorizedPaymentsInfo
      'click .info-note': @onClickInfoNote
      'click .load-transaction': @onClickLoadTransaction
      'click': @onClick

  onChangeAnonymousCheckbox: (event) ->
    Meteor.call "Retronator.Accounts.User.setShowSupporterName", not event.target.checked

  onClickLoadCreditInfo: (event) ->
    @showCreditInfo true
    @showAuthorizedPaymentsInfo false
    @currentTransaction null

  onClickLoadAuthorizedPaymentsInfo: (event) ->
    @showCreditInfo false
    @showAuthorizedPaymentsInfo true
    @currentTransaction null

  onClickInfoNote: (event) ->
    @showCreditInfo false
    @showAuthorizedPaymentsInfo false

  onClickLoadTransaction: (event) ->
    transaction = @currentData()
    @currentTransaction transaction
    
    @showCreditInfo false
    @showAuthorizedPaymentsInfo false

  onClick: (event) ->
    return if $(event.target).closest('.load-transaction').length

    @currentTransaction null

  # Components

  class @SupporterMessage extends AM.DataInputComponent
    @register 'LandsOfIllusions.Components.Account.Transactions.SupporterMessage'

    constructor: ->
      super

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
