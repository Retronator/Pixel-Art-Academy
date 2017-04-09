AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Account extends AM.Component
  @register 'LandsOfIllusions.Components.Account'
  @url: -> 'account'

  @version: -> '0.0.5'

  mixins: -> [@activatable]

  constructor: (@options) ->
    super

    @activatable = new LOI.Components.Mixins.Activatable()

    @lastTurnedPageNumber = 1
    @currentPageNumber = new ReactiveField 0

    @pages = [
      new @constructor.Contents
      new @constructor.General
      new @constructor.Services
      new @constructor.Characters
      new @constructor.Transactions
    ]

    page.pageNumber = index + 1 for page, index in @pages

    @emptyPages = for index in [@pages.length + 1..6]
      pageNumber: index

    LOI.Adventure.registerDirectRoute "#{@constructor.url()}/*", =>
      # Show the dialog if we need to.
      @show() if @activatable.deactivated()

      return unless pageUrl = FlowRouter.getParam 'parameter2'

      for page, index in @pages
        if page.constructor.url() is pageUrl
          @currentPageNumber index + 1

  onRendered: ->
    super

    # Animate page turning.
    @autorun (computation) =>
      return unless @activatable.activated()

      # We need to add turned pages if new current page number is bigger than the last turned one.
      currentPageNumber = @currentPageNumber()
      addingTurnedPages = currentPageNumber > @lastTurnedPageNumber

      if addingTurnedPages
        firstPageToTurn = @lastTurnedPageNumber
        lastPageToTurn = currentPageNumber - 1

      else
        firstPageToTurn = @lastTurnedPageNumber - 1
        lastPageToTurn = currentPageNumber

      for pageNumber in [firstPageToTurn..lastPageToTurn]
        do (pageNumber) =>
          $page = @$(".page-#{pageNumber}")

          distanceToFirstPage = Math.abs pageNumber - firstPageToTurn

          Meteor.setTimeout =>
            if addingTurnedPages
              $page.addClass('turned')

            else
              $page.removeClass('turned')
          ,
            distanceToFirstPage * 200

      @lastTurnedPageNumber = currentPageNumber

  show: ->
    LOI.adventure.menu.showModalDialog dialog: @

  url: ->
    url = 'account'
    pageNumber = @currentPageNumber()

    # Return the main URL while on the cover.
    return url unless pageNumber

    # Return the URL for the page.
    page = @pages[pageNumber - 1]
    "#{url}/#{page.constructor.url()}"

  onCoverClass: ->
    'on-cover' unless @currentPageNumber()

  pageClass: ->
    page = @currentData()

    "page-#{page.pageNumber}"

  coverClosedVisibleClass: ->
    'visible' unless @currentPageNumber()

  coverOpenVisibleClass: ->
    'visible' if @currentPageNumber()

  pageVisibleClass: ->
    page = @currentData()

    'visible' if @currentPageNumber() <= page.pageNumber

  pageImageUrl: ->
    page = @currentData()

    "/landsofillusions/components/account/page-#{page.pageNumber}.png"

  currentTabClass: ->
    page = @currentData()

    'current' if @currentPageNumber() is page.pageNumber

  tabName: ->
    page = @currentData()

    page.constructor.url()

  previousPage: ->
    @currentPageNumber Math.max 1, @currentPageNumber() - 1

  nextPage: ->
    @currentPageNumber Math.min @pages.length, @currentPageNumber() + 1

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      # Flip to first page if we're on the cover (we might be coming directly from URL).
      @currentPageNumber 1 unless @currentPageNumber()

      finishedActivatingCallback()
    ,
      750

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  backButtonCallback: ->
    =>
      currentPageNumber = @currentPageNumber()

      # Flip back to page 1.
      @currentPageNumber 1

      Meteor.setTimeout =>
        # Now flip to cover.
        @currentPageNumber 0

        Meteor.setTimeout =>
          @activatable.deactivate()
        ,
          500
      ,
        if currentPageNumber > 1 then currentPageNumber * 200 else 0

  events: ->
    super
