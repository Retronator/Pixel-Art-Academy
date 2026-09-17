AM = Artificial.Mirage

# Tracks which rendered elements are close enough to a scroll viewport to be visible. Callers describe the domain data
# represented by each element and handle visibility transitions, while the tracker owns measurements and lifecycle.
class AM.ElementVisibilityTracker
  # elements: callback that returns the DOM elements to track
  # scrollParent: optional window, DOM element, or jQuery object that scrolls (default: window)
  # viewportHeightDistance: optional number of viewport heights to track beyond each edge (default: 0)
  # measurementThrottleTime: optional scroll measurement throttle in seconds (default: 2)
  # visibilityUpdateThrottleTime: optional visibility update throttle in seconds (default: 0.2)
  # elementIdentityAndData: optional callback that returns 'identity' and 'data' for an element, with identity values compared strictly and data passed through to the lifecycle callbacks
  # visible: optional callback for elements entering the visibility distance
  # hidden: optional callback for elements leaving the visibility distance
  # destroyed: optional callback for element replacement, removal, and tracker destruction
  constructor: (@component, @options = {}) ->
    @_visibilityInfoByElement = new Map

    # Bind the listener once so it can be removed without using a shared event namespace.
    @_onScroll = =>
      @_throttledRefresh()
      @_throttledUpdateVisibility()

  start: ->
    return if @_started or @_destroyed

    @_started = true
    @_$scrollParent = $(@options.scrollParent or window)
    @_scrollParentIsWindow = @_$scrollParent[0] is window

    measurementThrottleTime = @options.measurementThrottleTime ? 2
    visibilityUpdateThrottleTime = @options.visibilityUpdateThrottleTime ? 0.2

    # Positions can change while scrolling, but measuring the DOM is more expensive than updating cached bounds.
    @_throttledRefresh = _.throttle (=> @refresh()), measurementThrottleTime * 1000
    @_throttledUpdateVisibility = _.throttle (=> @_updateVisibility()), visibilityUpdateThrottleTime * 1000

    @_$scrollParent.on 'scroll', @_onScroll

  refresh: ->
    return if @_destroyed or not @_started or not @component.isRendered()

    @_measureElements()
    @_updateVisibility()

  destroy: ->
    return if @_destroyed

    @_destroyed = true
    @_throttledRefresh?.cancel()
    @_throttledUpdateVisibility?.cancel()
    @_$scrollParent?.off 'scroll', @_onScroll

    visibilityInfoToDestroy = []
    @_visibilityInfoByElement.forEach (visibilityInfo) -> visibilityInfoToDestroy.push visibilityInfo

    @_destroyVisibilityInfo visibilityInfo for visibilityInfo in visibilityInfoToDestroy
    @_visibilityInfoByElement.clear()

  _measureElements: ->
    elements = @options.elements?() or []
    currentElements = new Set

    for element in elements
      currentElements.add element

      $element = $(element)
      top = $element.offset().top

      # Element offsets move with an element scroll parent, so convert them into its stable content coordinates.
      top += @_$scrollParent.scrollTop() unless @_scrollParentIsWindow

      bottom = top + $element.height()
      identityAndData = @options.elementIdentityAndData?(element) or {}

      # Identity values are compared strictly. Callers include every value whose change requires destruction and a new
      # visibility state, while other element data can update without resetting the current state.
      identity = identityAndData.identity ? []
      identity = [identity] unless _.isArray identity

      visibilityInfo = @_visibilityInfoByElement.get element

      # Blaze can retain an element while replacing the data or child media represented by it.
      if visibilityInfo and not @_identitiesMatch(visibilityInfo.identity, identity)
        @_destroyVisibilityInfo visibilityInfo
        @_visibilityInfoByElement.delete element
        visibilityInfo = null

      unless visibilityInfo
        visibilityInfo =
          element: element

        @_visibilityInfoByElement.set element, visibilityInfo

      visibilityInfo.top = top
      visibilityInfo.bottom = bottom
      visibilityInfo.identity = identity
      visibilityInfo.data = identityAndData.data

    # Destroy visibility info for elements removed by a reactive render before discarding their state.
    removedVisibilityInfo = []
    @_visibilityInfoByElement.forEach (visibilityInfo, element) ->
      removedVisibilityInfo.push visibilityInfo unless currentElements.has element

    for visibilityInfo in removedVisibilityInfo
      @_destroyVisibilityInfo visibilityInfo
      @_visibilityInfoByElement.delete visibilityInfo.element

  _updateVisibility: ->
    return if @_destroyed or not @_started or not @component.isRendered()

    viewportHeight = @_$scrollParent.height()
    viewportTop = @_$scrollParent.scrollTop()
    viewportTop += @_$scrollParent.offset().top unless @_scrollParentIsWindow
    viewportBottom = viewportTop + viewportHeight

    # The distance is measured in viewport heights and extends equally before and after the visible viewport.
    viewportHeightDistance = @options.viewportHeightDistance ? 0
    visibilityDistance = viewportHeightDistance * viewportHeight
    visibilityEdgeTop = viewportTop - visibilityDistance
    visibilityEdgeBottom = viewportBottom + visibilityDistance

    componentElements = @component.$children().toArray()
    removedVisibilityInfo = []

    @_visibilityInfoByElement.forEach (visibilityInfo) =>
      unless @_componentContainsElement visibilityInfo.element, componentElements
        removedVisibilityInfo.push visibilityInfo
        return

      elementShouldBeVisible = visibilityInfo.bottom > visibilityEdgeTop and
        visibilityInfo.top < visibilityEdgeBottom

      # Visible is intentionally undefined initially so every element receives its initial state transition.
      if elementShouldBeVisible and visibilityInfo.visible isnt true
        visibilityInfo.visible = true
        @options.visible? visibilityInfo

      else if not elementShouldBeVisible and visibilityInfo.visible isnt false
        visibilityInfo.visible = false
        @options.hidden? visibilityInfo

    # A throttled update can run after Blaze removes an element but before the next full measurement.
    for visibilityInfo in removedVisibilityInfo
      @_destroyVisibilityInfo visibilityInfo
      @_visibilityInfoByElement.delete visibilityInfo.element

  _componentContainsElement: (element, componentElements) ->
    for componentElement in componentElements
      return true if componentElement is element or componentElement.contains element

    false

  _identitiesMatch: (firstIdentity, secondIdentity) ->
    return false unless firstIdentity.length is secondIdentity.length

    for value, index in firstIdentity
      return false unless value is secondIdentity[index]

    true

  _destroyVisibilityInfo: (visibilityInfo) ->
    visibilityInfo.visible = false
    @options.destroyed? visibilityInfo
