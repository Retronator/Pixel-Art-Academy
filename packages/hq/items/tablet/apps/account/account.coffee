AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Items.Tablet.Apps.Account extends HQ.Items.Tablet.OS.App
  @register 'Retronator.HQ.Items.Tablet.Apps.Account'

  @id: -> 'Retronator.HQ.Items.Tablet.Apps.Account'
  @url: -> 'account'

  @fullName: -> "Account File"

  @description: ->
    "
      It's a all the documents with details about your account at Retronator.
    "

  @initialize()

  onCreated: ->
    super

    @subscribe Retronator.Accounts.User.loginServicesForCurrentUser
    @subscribe Retronator.Accounts.User.registeredEmailsForCurrentUser
    @subscribe Retronator.Accounts.User.supportAmountForCurrentUser
    @subscribe Retronator.Accounts.User.storeDataForCurrentUser
    @subscribe Retronator.Store.Transactions.Item.all
    @subscribe Retronator.Store.Transactions.Transaction.forCurrentUser

  loginServices: ->
    [
      'password'
      'facebook'
      'twitter'
      'google'
    ]

  loginServiceEnabled: ->
    serviceName = @currentData()
    user = Meteor.user()

    return unless user?.loginServices?

    serviceName in user.loginServices

  supportAmount: ->
    Retronator.user().supportAmount

  showSupporterName: ->
    Retronator.user().profile?.showSupporterName

  anonymousCheckboxAttributes: ->
    checked: true unless @showSupporterName()

  transactions: ->
    transactions = RS.Transactions.Transaction.findTransactionsForUser Retronator.user()
    return unless transactions

    transactions = transactions.fetch()

    # Refresh all items to get their names.
    for transaction in transactions
      for item in transaction.items
        item.item.refresh()

    transactions

  dateText: ->
    transaction = @currentData()
    languagePreference = AB.userLanguagePreference()

    transaction.time.toLocaleDateString languagePreference,
      day: 'numeric'
      month: 'long'
      year: 'numeric'

  claimLink: ->
    item = @currentData()
    item.givenGift.keyCode

  paymentAmount: ->
    payment = @currentData()
    payment.amount or payment.storeCreditAmount

  authorizedPaymentsAmount: ->
    Retronator.user().authorizedPaymentsAmount()

# Events

  events: ->
    super.concat
      'click .verify-email': @onClickVerifyEmail
      'submit .add-email-form': @onSubmitAddEmailForm
      'click .link-service': @onClickLinkService
      'change .anonymous-checkbox': @onChangeAnonymousCheckbox

  onClickVerifyEmail: (event) ->
    email = @currentData()

    Meteor.call 'Retronator.Accounts.User.sendVerificationEmail', email.address

  onSubmitAddEmailForm: (event) ->
    event.preventDefault()

    address = @$('.add-email-address').val()

    Meteor.call 'Retronator.Accounts.User.addEmail', address

  onClickLinkService: (event) ->
    serviceName = @currentData()

    Meteor["linkWith#{_.capitalize serviceName}"]()

  onChangeAnonymousCheckbox: (event) ->
    Meteor.call "Retronator.Accounts.User.setShowSupporterName", not event.target.checked

  # Components

  class @Username extends AM.DataInputComponent
    @register 'Retronator.Store.Pages.Account.Username'

    load: ->
      user = RA.User.documents.findOne Meteor.userId(),
        fields:
          'profile.name': 1

      user?.profile?.name

    save: (value) ->
      Meteor.call "Retronator.Accounts.User.rename", value

    placeholder: ->
      user = RA.User.documents.findOne Meteor.userId(),
        fields:
          displayName: 1

      user?.displayName

  class @SupporterName extends AM.DataInputComponent
    @register 'Retronator.HQ.Items.Tablet.Apps.Account.SupporterName'

    onCreated: ->
      super

      @_userBabelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'
      @_receiptBabelSubscription = AB.subscribeNamespace 'Retronator.HQ.Items.Tablet.Apps.ShoppingCart.Receipt'

    load: ->
      Retronator.user()?.profile?.supporterName

    save: (value) ->
      Meteor.call "Retronator.Accounts.User.setSupporterName", value

    placeholder: ->
      AB.translate(@_receiptBabelSubscription, 'Your name here').text
