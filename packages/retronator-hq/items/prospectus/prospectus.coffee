AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Prospectus extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Prospectus'
  @url: -> 'prospectus'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "school prospectus"
  @shortName: -> "prospectus"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's a hi-tech digital informational package about studying at Retropolis Academy of Art.
    "

  @initialize()

  # Listener

  onCommand: (commandResponse) ->
    prospectus = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Read], prospectus.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem prospectus

  class @Content extends AM.Component
    @register 'Retronator.HQ.Items.Prospectus.Content'

    onCreated: ->
      super

      @subscribe RS.Item.all

      @selectedItem = new ReactiveField null

    onRendered: ->
      super

      Tracker.afterFlush =>
        @measureSectionTops()

      $(window).on 'resize.prospectus', => @measureSectionTops()

      @_$mainWrapper = $('.retronator-hq-items-prospectus-content .main-wrapper')

      # Are we scrolling inside the body (about page) or inside the main wrapper (app)?
      @_$scrollTarget = if $('.pixelartacademy-landingpage-pages-about').length > 0 then $(window) else @_$mainWrapper
      @_$scrollTarget.on 'scroll.prospectus', => @watchScroll()

    onDestroyed: ->
      super

      $(window).off '.prospectus'
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
      $links = @$('nav > a')
      $hashes = ($(link).attr('href') for link in $links)

      @_sectionTops = []
      for hash in $hashes
        offset = $(hash).parent().position().top
        @_sectionTops.push $(hash).position().top - offset

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
        'click .play-button': @onClickPlayButton

    onClickSocialMediaIcon: (event) ->
      $icon = $(event.currentTarget)

      socialNetwork = null

      socialNetwork = 'Facebook' if $icon.hasClass('facebook')
      socialNetwork = 'Twitter' if $icon.hasClass('twitter')
      socialNetwork = 'Tumblr' if $icon.hasClass('tumblr')

      ga? 'send', 'event', 'Social Media Engagement', 'Click', socialNetwork if socialNetwork

    onClickPlayButton: (event) ->
      AB.Router.goToRoute 'LandsOfIllusions.Adventure'

  class @Purchase extends HQ.Items.Components.Stripe
    @id: -> 'Retronator.HQ.Items.Prospectus.Purchase'
    @register @id()

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
