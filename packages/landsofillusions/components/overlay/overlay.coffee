AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Overlay extends AM.Component
  @register 'LandsOfIllusions.Components.Overlay'

  onCreated: ->
    super

    @active = new ReactiveField false

    $('body').addClass('overlay-disable-scrolling')

  onRendered: ->
    super

    @_cropBarHeight = 0

    # Reactively resize elements.
    @autorun (computation) => @onResize()

    # See if we're inside of a component with activatable state - if yes, we can listen to know when to deactivate.
    activatableParent = @ancestorComponentWith 'activatedState'

    if activatableParent
      @autorun (computation) =>
        activatedState = activatableParent.callFirstWith(null, 'activatedState')

        switch activatedState
          when LOI.Adventure.Item.activatedStates.Activating
            @onActivating()

          when LOI.Adventure.Item.activatedStates.Deactivating
            @onDeactivating()

          when LOI.Adventure.Item.activatedStates.Deactivated
            @onDeactivated()

    @onActivating()

  onDestroyed: ->
    super

    $('body').removeClass('overlay-disable-scrolling')

  onActivating: ->
    @_cropBarHeight = 0

    @onResize force: true

    # Show transition cover.
    @$('.transition-cover').addClass('visible')

    # Fade in.
    @$('.landsofillusions-components-overlay').addClass('visible')

    Meteor.setTimeout =>
      @onActivated()
    ,
      600

    @$('.crop-bar').height 0

    @$('.crop-bar').velocity
      height: [@_cropBarHeight, 0]
    ,
      duration: 200
      easing: 'easeOutQuint'

  onActivated: ->
    return unless @isRendered()

    # Hide transition cover.
    @$('.transition-cover').removeClass('visible')
    @active true

  onDeactivating: ->
    @active false

    # Animate out.
    @$('.landsofillusions-components-overlay').removeClass('visible')
    @$('.transition-cover').addClass('visible')

    @$('.crop-bar').velocity
      height: 0
    ,
      duration: 200
      delay: 300
      easing: 'easeInQuint'

  onDeactivated: ->
    # Hide transition cover.
    @$('.transition-cover').removeClass('visible')

  onResize: (options) ->
    # Don't resize during animations. The function will re-run when active changes at the end.
    return unless @active() or options?.force

    # We allow use outside of adventure as well, in which case we just find the parent that holds the display.
    display = LOI.adventure?.interface.display or @callAncestorWith 'display'
    scale = display.scale()
    viewport = display.viewport()

    # Background can be at most 360px * scale high. Crop bars need to fill the rest when overlay is active.
    maxOverlayHeight = 360 * scale
    maxBoundsHeight = viewport.maxBounds.height()
    gapHeight = (maxBoundsHeight - maxOverlayHeight) / 2
    @_cropBarHeight = Math.max 0, viewport.maxBounds.top() + gapHeight

    safeAreaSize = viewport.safeArea.toDimensions()
    safeAreaSize.left += viewport.viewportBounds.left()
    safeAreaSize.top += viewport.viewportBounds.top()

    @$('.crop-bar').height @_cropBarHeight
    @$('.landsofillusions-components-overlay > .safe-area').css safeAreaSize

    # Inside the background the template in the else block can add
    # .max-area .viewport-area and .safe-area divs for us to position.

    viewportAreaSize = viewport.viewportBounds.toDimensions()
    maxAreaSize = viewport.maxBounds.toDimensions()

    viewportAreaSize.top = Math.max viewportAreaSize.top, @_cropBarHeight
    viewportAreaSize.height = Math.min viewportAreaSize.height, maxOverlayHeight

    maxAreaSize.height = maxOverlayHeight
    maxAreaSize.top = viewportAreaSize.top + (viewportAreaSize.height - maxAreaSize.height) * 0.5

    @$('.background .viewport-area').css viewportAreaSize
    @$('.background .max-area').css maxAreaSize
    @$('.background .safe-area').css safeAreaSize

    # Safe area content is not positioned absolutely so that it can grow container's content.
    # We use margins instead of positions to place it.
    @$('.background .safe-area-content').css
      marginLeft: safeAreaSize.left
      marginTop: safeAreaSize.top
      width: safeAreaSize.width
      minHeight: safeAreaSize.height

    # If the safe area appears inside the viewport area, we make it relative to the viewport.
    safeAreaSize.top -= viewportAreaSize.top

    @$('.background .viewport-area .safe-area').css top: safeAreaSize.top
    @$('.background .viewport-area .safe-area-content').css marginTop: safeAreaSize.top
