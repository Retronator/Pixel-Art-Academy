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

    # Are we scrolling inside the body (about page) or inside the main wrapper (app)?
    @_$scrollTarget = if $('.pixelartacademy-landingpage-pages-about').length > 0 then $(window) else @_$mainWrapper
    @_$scrollTarget.on 'scroll.prospectus', => @watchScroll()

  onDestroyed: ->
    super

    $(document).off '.prospectus'
    @_$scrollTarget.off '.prospectus'

  iosClass: ->
    'ios' if /iPad|iPhone|iPod/.test(navigator.userAgent) and not window.MSStream

  backgroundSize: ->
    display = LOI.adventure.interface.display
    width = display.viewport().viewportBounds.width()
    scale = display.scale()

    tabletWidth = 300 * scale

    tabletWidth / width * 100

  backgroundPositionY: ->
    display = LOI.adventure.interface.display
    height = display.viewport().viewportBounds.height()
    scale = display.scale()

    tabletHeight = 200 * scale

    bottomGapPercentage = (1 - tabletHeight / height)

    (1 + bottomGapPercentage) * 100

  measureSectionTops: ->
    # Get scroll top positions of all sections.
    $links = $('nav > a')
    $hashes = _.tail ($(link).attr('href') for link in $links)

    @_sectionTops = [0]
    @_sectionTops.push $(hash).position().top for hash in $hashes

  watchScroll: ->
    active = 0
    index = null

    scrollPositionTop = @_$scrollTarget.scrollTop()
    scrollPositonBotttom = scrollPositionTop + @_$scrollTarget.height()

    for i in [0...@_sectionTops.length]
      if scrollPositonBotttom > @_sectionTops[i]
        active = i

    if active isnt index
      index = active
      $('nav > a').removeClass('active')
      $('nav > a:eq(' + index + ')').addClass('active')

  events: ->
    super.concat
      'click .social-media-icon': @onClickSocialMediaIcon
      'click .purchase-product': @processItemId
      'click .close-payment': @resetItemId

  onClickSocialMediaIcon: (event) ->
    $icon = $(event.target)

    socialNetwork = null

    socialNetwork = 'Facebook' if $icon.hasClass('facebook')
    socialNetwork = 'Twitter' if $icon.hasClass('twitter')
    socialNetwork = 'Tumblr' if $icon.hasClass('tumblr')

    ga 'send', 'event', 'Social Media Engagement', 'Click', socialNetwork if socialNetwork

  resetItemId: (event) ->
    @selectedItem null

    # Re-enable scrolling when the payment form is closed.
    $('body, html').removeClass('prospectus-disable-scrolling')

  processItemId: (event) ->
    item = @currentData()
    @selectedItem item

    ga 'send', 'event', 'Game Selected', 'Click', item.catalogKey

    # Disable scrolling when the payment form is active.
    $('body').addClass('prospectus-disable-scrolling')

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
