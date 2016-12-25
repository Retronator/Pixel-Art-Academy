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

    @subscribe RS.Transactions.Item.all

    @selectedItem = new ReactiveField null

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
      'click .purchase-product': @processItemId
      'click .close-payment': @resetItemId

  resetItemId: (event) ->
    @selectedItem null

    # Re-enable scrolling when the payment form is closed.
    $('body, html').removeClass('disable-scrolling')

  processItemId: (event) ->
    item = @currentData()
    @selectedItem item

    # Disable scrolling when the payment form is active.
    $('body, html').addClass('disable-scrolling')

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

      [
        item: selectedItem
        isGift: false
      ]

    paymentAmount: ->
      selectedItem = @data()

      selectedItem.price
