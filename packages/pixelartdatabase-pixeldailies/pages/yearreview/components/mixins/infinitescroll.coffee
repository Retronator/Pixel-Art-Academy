AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Components.Mixins.InfiniteScroll
  # - count: reactive field with the number of items displayed.
  constructor: (@options = {}) ->
    @options.step ?= 1
    @options.windowHeightCounts ?= 1
    @count = new ReactiveField 0
    @limit = new ReactiveField @options.step

  onRendered: ->
    @_$window = $(window)
    @_$body = $('body')

    @_$window.on 'scroll.infinite-scroll', (event) => @onScroll()
    @onScroll()

  onDestroyed: ->
    @_$window.off '.infinite-scroll'

  # Call this to tell the mixin how many items (out of the limit) have been loaded.
  updateCount: (value) ->
    # Update the number with a delay so that things get time to load and render and change the height of the document.
    Meteor.setTimeout =>
      @count value
      @update()
    ,
      1000

  onScroll: ->
    @update()

  update: (options) ->
    scrollTop = @_$window.scrollTop()

    # Increase limit when we're inside the last few window heights of the page.
    windowHeightsFactor = @options.windowHeightCounts + 1
    triggerTop = @_$body.height() - @_$window.height() * windowHeightsFactor

    if scrollTop > triggerTop
      # Only increase the limit if we actually have that many artworks on the client.
      if @limit() is @count()
        @limit @limit() + @options.step
