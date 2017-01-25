AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Top2016.Components.Mixins.InfiniteScroll
  # - count: reactive field with the number of items displayed.
  constructor: (@options = {}) ->
    @options.step ?= 1
    @count = new ReactiveField 0
    @limit = new ReactiveField @options.step

  onRendered: ->
    @_$window = $(window)
    @_$body = $('body')

    @_$window.on 'scroll.infinite-scroll', (event) => @onScroll()
    @_$window.on 'wheel.infinite-scroll', (event) => @onWheel()
    @onScroll()

  onDestroyed: ->
    @_$window.off '.infinite-scroll'

  updateCount: (value) ->
    # Update the number with a delay so that things get time to load and render and change the height of the document.
    Meteor.setTimeout =>
      @count value
    ,
      1000

  onScroll: ->
    @update()

  onWheel: ->
    @update measureTranslate: true

  update: (options) ->
    if options?.measureTranslate
      scrollTop = -parseInt $.Velocity.hook(@_$body, 'translateY') or 0

    else
      scrollTop = @_$window.scrollTop()

    # Increase limit when we're inside the last 2 window heights of the page.
    triggerTop = @_$body.height() - @_$window.height() * 3

    if scrollTop > triggerTop
      # Only increase the limit if we actually have that many artworks on the client.
      if @limit() is @count()
        @limit @limit() + @options.step
