AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Account extends AM.Component
  @register 'LandsOfIllusions.Components.Account'

  @version: -> '0.0.3'

  constructor: (@options) ->
    super

    @activatable = new LOI.Components.Mixins.Activatable()

    @currentPageNumber = new ReactiveField 0

    @contentsPage = new @constructor.General

    @pages = [
      new @constructor.Services
      new @constructor.Characters
    ]

    page.pageNumber = index + 2 for page, index in @pages

    @emptyPages = for index in [@pages.length..5]
      pageNumber: index

    LOI.Adventure.registerDirectRoute 'account/*', =>
      # Show the dialog if we need to.
      @show() if @activatable.deactivated()

      return unless pageUrl = FlowRouter.getParam 'parameter2'

      for page, index in @pages
        if page.constructor.url() is pageUrl
          @currentPageNumber index + 1

  mixins: -> [@activatable]

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
      # Flip to first page.
      @currentPageNumber 1

      finishedActivatingCallback()
    ,
      1000

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  backButtonCallback: ->
    =>
      # Flip back to cover.
      @currentPageNumber 0
      Meteor.setTimeout =>
        @activatable.deactivate()
      ,
        500

  events: ->
    super
