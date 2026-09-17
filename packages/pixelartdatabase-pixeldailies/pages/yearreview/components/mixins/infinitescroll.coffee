AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Components.Mixins.InfiniteScroll
  # - count: reactive field with the number of items displayed.
  constructor: (@options = {}) ->
    @options.step ?= 1
    @options.windowHeightCounts ?= 1
    @options.countCanDifferFromLimit ?= false
    @options.countSettlingDelay ?= 200
    @count = new ReactiveField 0
    @limit = new ReactiveField @options.step

    # Track which result count already caused a limit increase so an exhausted query does not keep loading.
    @_countAtLastLimitIncrease = null
    @_countHasSettled = false
    @_countSettlingTimeout = null

  onRendered: ->
    @_$window = $(window)
    @_$body = $('body')

    @_$window.on 'scroll.infinite-scroll', (event) => @onScroll()
    @onScroll()

  onDestroyed: ->
    @_destroyed = true
    @_$window?.off '.infinite-scroll'
    @_$window = null
    @_$body = null

    Meteor.clearTimeout @_countSettlingTimeout

  # Call this to tell the mixin how many items (out of the limit) have been loaded.
  updateCount: (value) ->
    # Update the number after new documents have finished rendering.
    Tracker.afterFlush =>
      return if @_destroyed

      @count value

      if @options.countCanDifferFromLimit
        # Result documents can arrive one at a time. Only use an incomplete count after it has stopped changing,
        # otherwise each arriving document would request another page and restart the subscription.
        @_countHasSettled = false
        Meteor.clearTimeout @_countSettlingTimeout
        @_countSettlingTimeout = Meteor.setTimeout =>
          return if @_destroyed

          @_countSettlingTimeout = null
          @_countHasSettled = true
          @update()
        , @options.countSettlingDelay

      @update()

  onScroll: ->
    @update()

  update: (options) ->
    return unless @_$window
    scrollTop = @_$window.scrollTop()

    # Increase limit when we're inside the last few window heights of the page.
    windowHeightsFactor = @options.windowHeightCounts + 1
    triggerTop = @_$body.height() - @_$window.height() * windowHeightsFactor

    return unless scrollTop > triggerTop
    return unless count = @count()

    if @options.countCanDifferFromLimit
      return unless @_countHasSettled

    else
      # Most result sets have one displayed item per requested document, so only continue after the page is complete.
      return unless count is @limit()

    # Wait for the count to change before increasing again to avoid repeatedly requesting past the end of the results.
    return if count is @_countAtLastLimitIncrease

    @_countAtLastLimitIncrease = count
    @limit @limit() + @options.step
