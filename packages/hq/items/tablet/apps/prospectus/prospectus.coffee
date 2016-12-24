AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RS = Retronator.Store

class HQ.Items.Tablet.Apps.Prospectus extends HQ.Items.Tablet.OS.App
  @register 'Retronator.HQ.Items.Tablet.Apps.Prospectus'

  @id: -> 'Retronator.HQ.Items.Tablet.Apps.Prospectus'
  @url: -> 'pixelartacademy'

  @fullName: -> "Pixel Art Academy Prospectus"

  @description: ->
    "
      Informational package about studying at Retropolis Academy of Art.
    "

  @initialize()

  onCreated: ->
    super

    @_itemsSubscription = @subscribe RS.Transactions.Item.all
    @selectedItem = new ReactiveField null

    @stripeInitialized = new ReactiveField false

    @purchaseError = new ReactiveField null
    @submittingPayment = new ReactiveField false
    @purchaseCompleted = new ReactiveField false
    
  onRendered: ->
    super

    @measureSectionTops()
    $(document).on 'resize.prospectus', => @measureSectionTops()

    @_$mainWrapper = $('.retronator-hq-items-tablet-apps-prospectus .main-wrapper')
    @_$mainWrapper.on 'scroll.prospectus', => @watchScroll()

  onDestroyed: ->
    super

    $(document).off '.prospectus'
    @_$mainWrapper.off '.prospectus'

  iosClass: ->
    'ios' if /iPad|iPhone|iPod/.test(navigator.userAgent) and not window.MSStream

  backgroundSize: ->
    display = @options.adventure.interface.display
    width = display.viewport().viewportBounds.width()
    scale = display.scale()

    tabletWidth = 300 * scale

    tabletWidth / width * 100

  backgroundPositionY: ->
    display = @options.adventure.interface.display
    height = display.viewport().viewportBounds.height()
    scale = display.scale()

    tabletHeight = 200 * scale

    bottomGapPercentage = (1 - tabletHeight / height)

    (1 + bottomGapPercentage) * 100

  measureSectionTops: ->
    # Get scroll top positions of all sections.
    $links = $('nav > a')
    $hashes = ($(link).attr('href') for link in $links)
    @_sectionTops = ($(hash).position().top for hash in $hashes)

  watchScroll: ->
    active = 0
    index = null
    scrollPosTop = @_$mainWrapper.scrollTop()
    scrollPosBot = scrollPosTop + @_$mainWrapper.height()

    for i in [0...@_sectionTops.length]
      if scrollPosBot > @_sectionTops[i]
        active = i

    if active != index
      index = active
      $('nav > a').removeClass('active')
      $('nav > a:eq(' + index + ')').addClass('active')

  events: ->
    super.concat
      'submit #payment-form': @tokenizeCreditCard
      'click .purchase-product': @processItemId
      'click .close-payment': @resetItemId
      'click .reset-payments': @resetPayments

  resetPayments: (event) ->
    @paymentSuccess null
    @paymentFailure null
    $('#payment-form input').val('')
    @paymentErrors null
    $('#payment-form button').prop('disabled', false)

  resetItemId: (event) ->
    @selectedItem null

    # Re-enable scrolling when the payment form is closed.
    $('body, html').removeClass('disable-scrolling')

  processItemId: (event) ->
    item = @currentData()
    @selectedItem item

    # Disable scrolling when the payment form is active.
    $('body, html').addClass('disable-scrolling')

  tokenizeCreditCard: (event) ->
    #stop the form from submitting so we can control it
    event.preventDefault()

    #grab all customer inputs needed to tokenize credit card
    $creditCardName = $('[data-stripe="name"]').val()
    $creditCardNumber = $('[data-stripe="number"]').val()
    $creditCardCvc = $('[data-stripe="cvc"]').val()
    $creditCardExpirationMonth = $('[data-stripe="exp-month"]').val()
    $creditCardExpirationYear = $('[data-stripe="exp-year"]').val()

    #inform user of client-side validation errors
    if not Stripe.card.validateCardNumber($creditCardNumber)
      @paymentErrors "Invalid card number! Please check your inputs and try again."
      return

    if not Stripe.card.validateExpiry($creditCardExpirationMonth, $creditCardExpirationYear)
      @paymentErrors "Invalid expiry date! Please make sure that the date is in the future"
      return

    if not Stripe.card.validateCVC($creditCardCvc)
      @paymentErrors "Invalid CVC. Please check your inputs and try again."
      return

    $('#payment-form button').prop('disabled', true)
    @submittingPayment true

    # If it passes validations, go ahead and create the token.
    Stripe.card.createToken {
      name: $creditCardName
      number: $creditCardNumber
      cvc: $creditCardCvc
      exp_month: $creditCardExpirationMonth
      exp_year: $creditCardExpirationYear
    }, (status, response) =>
      @stripeResponseHandler(status, response)

#when we get a response from stripe
  stripeResponseHandler: (status, response) ->

#if there's an error, let our user know and let them try again
    if response.error
      @paymentErrors response.error.message
      $('#payment-form button').prop('disabled', false)
      return

    #otherwise, clear the errors they may have accrued and send the information to the server
    #needed to make a new customer/save their card information
    @paymentErrors null

    #grab tokenized credit card
    creditCardToken = response.id
    #grab the customer details
    customer =
      email: $('[name="customer-email"]').val()
      name: $('[data-stripe="name"]').val()

    #pass customer to the server to create
    Retronator.Store.server.call 'Retronator.Store.Purchase.insertStripePurchase', customer, creditCardToken, @selectedItem(), (error, data) =>
      @submittingPayment false

      if error
        @paymentErrors error.reason
        @paymentFailure true
        $('#payment-form button').prop('disabled', false)
        return

      @paymentFailure null
      # Google Analytics: trigger success event
      window.dataLayer = window.dataLayer || []
      window.dataLayer.push({
        'event' : 'Game Purchased'
        'purchase_label' : @selectedItem().name
        'value' : @selectedItem().priceMinimum
      })
      return @paymentSuccess true

  basicGame: ->
    RS.Transactions.Item.documents.findOne catalogKey: RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame

  fullGame: ->
    RS.Transactions.Item.documents.findOne catalogKey: RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FullGame

  alphaAccess: ->
    RS.Transactions.Item.documents.findOne catalogKey: RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccess

  class @Purchase extends HQ.Items.Tablet.Apps.Components.Stripe
    @register 'Retronator.HQ.Items.Tablet.Apps.Prospectus.Purchase'

    purchaseItem: ->
      selectedItem = @data()

      # Load bundle items as well.
      for bundleItem in selectedItem.items
        bundleItem.refresh()

      selectedItem
      
    purchaseItems: ->
      selectedItem = @data()

      item: selectedItem
      isGift: false
