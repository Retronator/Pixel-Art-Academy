AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Account extends AM.Component
  @register 'LandsOfIllusions.Components.Account'

  @version: -> '0.0.2'

  constructor: ->
    super

    @activatable = new LOI.Components.Mixins.Activatable()

    @currentPageNumber = new ReactiveField 0

    @pages = [
      new @constructor.General
    ]

    page.pageNumber = index + 1 for page, index in @pages

    @emptyPages = for index in [@pages.length..5]
      pageNumber: index

  mixins: -> [@activatable]

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

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      finishedActivatingCallback()
    ,
      500

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  backButtonCallback: ->
    =>
      # Flip back to cover if needed.
      if @currentPageNumber()
        @currentPageNumber 0
        Meteor.setTimeout =>
          @activatable.deactivate()
        ,
          500

      else
        @activatable.deactivate()

  events: ->
    super.concat
      'click .cover-button': @onClickCoverButton
      'click .previous': @onClickPrevious
      'click .next': @onClickNext

  onClickCoverButton: (event) ->
    @currentPageNumber 1

  onClickPrevious: (event) ->
    @currentPageNumber _.clamp @currentPageNumber() - 1, 0, @pages.length

  onClickNext: (event) ->
    @currentPageNumber _.clamp @currentPageNumber() + 1, 0, @pages.length
