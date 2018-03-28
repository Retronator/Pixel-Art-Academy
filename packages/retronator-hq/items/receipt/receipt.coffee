AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
RA = Retronator.Accounts
RS = Retronator.Store
HQ = Retronator.HQ

class HQ.Items.Receipt extends HQ.Items.Components.Stripe
  @id: -> 'Retronator.HQ.Items.Receipt'
  @url: -> 'retronator/store/receipt'

  @register @id()
  template: -> @id()

  @version: -> '0.0.1'

  @fullName: -> "store receipt"
  @shortName: -> "receipt"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's the receipt for things you bought in Retronator Store.
    "

  @initialize()

  constructor: (@options) ->
    super

    # Fields that control supporter display for logged out users (guests).
    @guestShowSupporterName = @state.field 'showSupporterName', default: true
    @guestSupporterName = @state.field 'supporterName'

    @tipStateFields =
      amount: @state.field 'tip.amount', default: 0
      message: @state.field 'tip.message'

    @scrolled = new ReactiveField false
    @scrolledToBottom = new ReactiveField false

    @europeanUnion = @state.field 'europeanUnion', default: false
    @country = @state.field 'country'
    @business = @state.field 'business', default: false
    @vatId = @state.field 'vatId'

    @vatIdError = new ReactiveField null
    @vatIdName = new ReactiveField null

    @purchaseItems = new ReactiveField []

    @usdToEurExchangeRate = new ReactiveField null

  onCreated: ->
    super

    @vatSummaryError = new ComputedField =>
      return "You need to enter your billing country to calculate VAT." unless @country()
      return "You need to enter your VAT ID, otherwise choose consumer." if @business() and not @vatId()
      null

    @scrolled false
    @scrolledToBottom false

    # Get all store items data.
    @subscribe RS.Item.all

    # Get top recent transactions to display the supporters list.
    @subscribe RS.Transaction.topRecent

    # Get store balance and credit so we know if credit can be applied (and the user charged less).
    @subscribe RA.User.storeDataForCurrentUser

    # Get stored payment methods.
    RS.PaymentMethod.forCurrentUser.subscribe @

    # Get user's contact email so we can pre-fill it in Stripe Checkout.
    @subscribe RA.User.contactEmailForCurrentUser

    @_userBabelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'

    @autorun (computation) =>
      contents = HQ.Items.ShoppingCart.state 'contents'

      purchaseItems = for receiptItem in contents
        item = RS.Item.documents.findOne catalogKey: receiptItem.item
        continue unless item

        item: item
        isGift: receiptItem.isGift

      @purchaseItems purchaseItems

    # Validate VAT ID.
    @autorun (computation) =>
      # Reset the error as we will display a new one after validation, if necessary.
      @vatIdError null

      # VAT ID is only needed for EU businesses.
      return unless @europeanUnion() and @business()

      # React to VAT ID and country changes.
      return unless vatId = @vatId()
      return unless country = @country()

      # Make sure the country matches.
      vatIdCountry = vatId[0..1].toLowerCase()
      vatIdCountry = 'gr' if vatIdCountry is 'el'

      unless country is vatIdCountry
        @vatIdError reason: "VAT ID doesn't match your country selection."
        return

      # Also validate ID to notify the user in advance if there will be any errors.
      RS.Vat.validateVatId vatId, (error, result) =>
        if error
          @vatIdError error
          return

        # Show the company name for 8 seconds.
        @vatIdName result.name

        Meteor.setTimeout =>
          @vatIdName null
        ,
          8000

    RS.Vat.ExchangeRate.getUsdToEur (error, value) =>
      if error
        console.error error
        return

      @usdToEurExchangeRate value

  onRendered: ->
    super

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    @display = LOI.adventure.getCurrentThing HQ.Store.Display

    $displayScene = @display.$('.scene')
    $messageArea = @$('.message-area')
    @_$translateAreas = $displayScene.add($messageArea)

    @_$background = @$('.background')
    @_$safeArea = @$('.safe-area')
    @_$safeAreaContent = @$('.safe-area-content')
    @_$receipt = @_$safeAreaContent.find('.receipt')

    @_$background.scroll (event) =>
      @scrolled @_$background.scrollTop() > 0

    Meteor.setTimeout =>
      @_scrollToNewSupporter duration: 1000
    ,
      1000

  onDestroyed: ->
    super

    @app?.removeComponent @

  draw: ->
    # After we go pass the end of the receipt, move the display scene.
    scrollTop = @_$background.scrollTop()
    return if scrollTop is @_lastScrollTop

    safeAreaHeight = @_$safeArea.height()
    receiptBottom = @_$receipt.outerHeight()

    # Make sure there is a receipt at all. It will get removed when payment completes.
    if receiptBottom
      sceneOffset = Math.min 0, receiptBottom - safeAreaHeight - scrollTop

    else
      sceneOffset = 0

    @scrolledToBottom sceneOffset < 0

    @_lastScrollTop = scrollTop

  showSupporterName: ->
    user = Retronator.user()

    if user then user.profile?.showSupporterName else @guestShowSupporterName()

  supporterName: ->
    return unless @showSupporterName()

    user = Retronator.user()

    if user then user.profile.name else @guestSupporterName()
    
  anonymousPlaceholder: ->
    AB.translate(@_userBabelSubscription, 'Anonymous').text
    
  anonymousYesAttributes: ->
    checked: true if @showSupporterName()

  anonymousNoAttributes: ->
    checked: true unless @showSupporterName()

  europeanUnionYesAttributes: ->
    checked: true if @europeanUnion()

  europeanUnionNoAttributes: ->
    checked: true unless @europeanUnion()

  europeanUnionAreaVisibleClass: ->
    'visible' if @europeanUnion()

  europeanUnionConsumerAttributes: ->
    checked: true unless @business()

  europeanUnionBusinessAttributes: ->
    checked: true if @business()

  # HACK: For whatever reason we can't use the fields directly.
  isEuropeanUnion: -> @europeanUnion()
  isBusiness: -> @business()
  vatIdEntry: -> @vatId()
  vatCountry: -> @country()

  itemsPrice: ->
    # The sum of all items to be purchased.
    _.sum (storeItem.item.price for storeItem in @purchaseItems())

  totalPrice: ->
    # Total is the items price with added tip.
    @itemsPrice() + (@tipStateFields.amount() or 0)

  storeCredit: ->
    Retronator.user()?.store?.credit or 0

  creditApplied: ->
    # Credit is applied up to the amount in the shopping cart.
    Math.min @storeCredit(), @totalPrice()

  paymentAmount: ->
    # See how much the user will need to pay to complete this transaction, after the credit is applied.
    storeCredit = Retronator.user()?.store?.credit or 0

    # Existing store credit decreases the needed amount to pay, but of course not below zero.
    Math.max 0, @totalPrice() - storeCredit

  topRecentTransactions: ->
    # First get the existing top 10.
    recentTransactions = RS.Components.TopSupporters.topRecentTransactions.find({},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]
    ).fetch()

    # Mark as existing transactions.
    transaction.existing = true for transaction in recentTransactions

    # Create new transaction.
    newTransaction =
      name: @supporterName()
      amount: @totalPrice()
      new: true

    newTransaction.message = @tipStateFields.message() if @tipStateFields.amount()

    # Find where the new transaction needs to be inserted. We use
    # a negative amount because the list is in descending order.
    insertIndex = _.sortedIndexBy recentTransactions, newTransaction, (transaction) -> -transaction.amount

    # Add the new transaction and return the result.
    recentTransactions.splice insertIndex, 0, newTransaction
    recentTransactions

  # This overrides the tip plain object in Stripe component parent.
  tip: ->
    amount: @tipStateFields.amount()
    message: @tipStateFields.message()

  paymentMethods: ->
    RS.PaymentMethod.documents.find()

  showNewPaymentMethod: ->
    @stripeInitialized() and @paymentAmount() and Meteor.userId()

  oneTimeStripeSelected: ->
    @selectedPaymentMethod()?.paymentMethod.type is HQ.Items.Components.Stripe.PaymentMethods.StripePayment

  showPaymentInfo: ->
    @selectedPaymentMethod() or not @paymentAmount()

  dateText: ->
    languagePreference = AB.userLanguagePreference()

    new Date().toLocaleDateString languagePreference,
      day: 'numeric'
      month: 'numeric'
      year: 'numeric'

  purchaseErrorText: ->
    return unless error = @purchaseError()

    errorText = "#{error.reason}"
    errorText = "#{errorText} #{error.details}" if error.details

    errorText

  purchaseErrorAfterCharge: ->
    return unless error = @purchaseError()
    error.error is RS.Transaction.serverErrorAfterPurchase

  vatIdErrorText: ->
    return unless error = @vatIdError()

    errorText = "#{error.reason}"
    errorText = "#{errorText} #{error.details}" if error.details

    errorText

  showingFinalMessage: ->
    # We show only the dialog message (and hide the receipt and payment presenter) when the purchase has gone through.
    @purchaseCompleted() or @purchaseErrorAfterCharge()

  vatCharged: ->
    # VAT is always charged in Slovenia and for consumers outside Slovenia.
    @country() is 'si' or not @business()

  vatRate: ->
    RS.Vat.Rates.Standard[@country()]

  vatRatePercentage: ->
    @vatRate() * 100

  paymentAmountEur: ->
    return unless usdToEurExchangeRate = @usdToEurExchangeRate()

    paymentAmountEur = @paymentAmount() * usdToEurExchangeRate

    # Amount needs to be reported with 2 decimal digits.
    Math.round(paymentAmountEur * 100) / 100

  vatAmountEur: ->
    return unless paymentAmountEur = @paymentAmountEur()

    vatRate = @vatRate()
    vatRatio = vatRate / (1 + vatRate)

    vatEur = paymentAmountEur * vatRatio

    # VAT needs to be reported with 2 decimal digits.
    Math.round(vatEur * 100) / 100

  paymentAmountWithoutVatEur: ->
    return unless paymentAmountEur = @paymentAmountEur()
    return unless vatAmountEur = @vatAmountEur()

    paymentAmountEur - vatAmountEur

  events: ->
    super.concat
      'change .european-union-radio': @onChangeEuropeanUnionRadio
      'change .european-union-entity-radio': @onChangeEuropeanUnionEntityRadio
      'change .vat-id': @onChangeVatId
      'change .anonymous-radio': @onChangeAnonymousRadio
      'input .supporter-name': @onInputSupporterName
      'input .tip-amount': @onInputTipAmount
      'input .tip-message': @onInputTipMessage
      'click .one-time-payment .one-time-stripe': @onClickOneTimePaymentStripe
      'click .deselect-payment-method-button': @onClickDeselectPaymentMethodButton

  onChangeEuropeanUnionRadio: (event) ->
    @europeanUnion parseInt($(event.target).val()) is 1

  onChangeEuropeanUnionEntityRadio: (event) ->
    @business parseInt($(event.target).val()) is 1

  onChangeVatId: (event) ->
    @vatId $(event.target).val()

  onChangeAnonymousRadio: (event) ->
    showSupporterName = parseInt($(event.target).val()) is 1

    if Meteor.userId()
      Meteor.call "Retronator.Accounts.User.setShowSupporterName", showSupporterName

    else
      @guestShowSupporterName showSupporterName

  onInputSupporterName: (event) ->
    name = $(event.target).val()
    @guestSupporterName name

  onInputTipAmount: (event) ->
    enteredString = $(event.target).val()

    # Make sure the entered value is a number.
    try
      enteredValue = parseFloat enteredString

    catch
      enteredValue = 0

    # If negative sign is entered the parsing succeeds with a NaN value.
    enteredValue = 0 if _.isNaN enteredValue

    # Constrain between 0 and 1000 and round to dollar amount.
    value = Math.floor _.clamp enteredValue, 0, 1000

    # Rewrite the value in the input if needed.
    newString = "#{value}"
    $(event.target).val newString unless newString is enteredString

    oldValue = @tipStateFields.amount()
    @tipStateFields.amount value

    @display.smile() if value > oldValue

    @_scrollToNewSupporter()

  _scrollToNewSupporter: (options = {}) ->
    options.duration ?= 200

    Tracker.afterFlush =>
      $newSupporter = $('.retronator-store-components-top-supporters .new.supporter')

      # Scroll to one higher if possible so that the user sees how much they need to go higher.
      $previousSupporter = $newSupporter.prev()
      $scrollTarget = if $previousSupporter.length then $previousSupporter else $newSupporter
      $scrollContainer = $('.retronator-hq-store-display .screen .content-area')
      middleHeight = $scrollContainer.outerHeight() / 2
      targetTop = $scrollTarget.position().top - middleHeight

      $scrollContainer.stop().animate scrollTop: targetTop, options.duration

  onInputTipMessage: (event) ->
    message = $(event.target).val()
    @tipStateFields.message message

  _onSubmittingPayment: ->
    # Scroll to top.
    @$('.safe-area-content').velocity 'scroll',
      container: @$('.background')

  _displayError: (error) ->
    super

    # If the error has happened after purchase, we still want to clean up.
    @_resetAfterPurchase() if @purchaseErrorAfterCharge()

  _completePurchase: ->
    super

    # We set this to true because adventure script will use it to determine how to branch the dialog.
    @transactionCompleted = true

    @display.smile()

    @_resetAfterPurchase()

    # deactivate receipt after 4 seconds.
    Meteor.setTimeout =>
      @deactivate()
    ,
      4000

  _resetAfterPurchase: ->
    # Reset the shopping cart state.
    HQ.Items.ShoppingCart.clearItems()

    # Reset the tip
    @tipStateFields.amount 0
    @tipStateFields.message null

  onClickDeselectPaymentMethodButton: ->
    @selectedPaymentMethod null

  onClickOneTimePaymentStripe: ->
    @selectedPaymentMethod
      paymentMethod:
        type: HQ.Items.Components.Stripe.PaymentMethods.StripePayment

  # Components

  class @EuropeanCountrySelection extends AB.Components.RegionSelection
    @register 'Retronator.HQ.Items.Receipt.EuropeanCountrySelection'

    constructor: ->
      super

      @regionList = AB.Region.Lists.EuropeanUnion

    onCreated: ->
      super

      @receipt = @ancestorComponentOfType HQ.Items.Receipt

    load: ->
      @receipt.country() or ''

    save: (value) ->
      @receipt.country value

  class @SupporterName extends AM.DataInputComponent
    @register 'Retronator.HQ.Items.Receipt.SupporterName'

    load: ->
      user = RA.User.documents.findOne Meteor.userId(),
        fields:
          'profile.name': 1

      user?.profile?.name

    save: (value) ->
      Meteor.call "Retronator.Accounts.User.rename", value

    placeholder: ->
      # We display the same placeholder as with the custom input when we're not logged in.
      receipt = @parentComponent()
      AB.translateForComponent(receipt, 'Your name here').text

  class @StripePaymentMethod extends AM.Component
    @register 'Retronator.HQ.Items.Receipt.StripePaymentMethod'

    onCreated: ->
      super

      @loading = new ReactiveField false
      @receipt = @ancestorComponentOfType HQ.Items.Receipt

      @selected = new ComputedField =>
        paymentMethod = @data()
        @receipt.selectedPaymentMethod()?.paymentMethod is paymentMethod

    loadingClass: ->
      'loading' if @loading()

    events: ->
      super.concat
        'click .case': @onClickCase

    onClickCase: (event) ->
      # See if this payment method is already selected.
      if @selected()
        # Deselect it.
        @receipt.selectedPaymentMethod null
        return

      # Load customer data.
      @loading true

      paymentMethod = @data()
      RS.PaymentMethod.getStripeCustomerData paymentMethod._id, (error, customerData) =>
        @loading false

        if error
          console.error error
          return

        # We have the data, select the payment method.
        @receipt.selectedPaymentMethod {paymentMethod, customerData}
