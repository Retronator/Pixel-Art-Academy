AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Overlay extends AM.Component
  @register 'LandsOfIllusions.Components.Overlay'

  onCreated: ->
    super

    $('body').addClass('overlay-disable-scrolling')

  onRendered: ->
    super

    cropBarHeight = 0

    # Resize elements.
    @autorun (computation) =>
      scale = LOI.adventure.interface.display.scale()
      viewport = LOI.adventure.interface.display.viewport()

      # Background can be at most 360px * scale high. Crop bars need to fill the rest when overlay is active.
      maxOverlayHeight = 360 * scale
      maxBoundsHeight = viewport.maxBounds.height()
      gapHeight = (maxBoundsHeight - maxOverlayHeight) / 2
      cropBarHeight = Math.max 0, viewport.maxBounds.top() + gapHeight

      safeAreaSize = viewport.safeArea.toDimensions()
      safeAreaSize.left += viewport.viewportBounds.left()
      safeAreaSize.top += viewport.viewportBounds.top()

      @$('.crop-bar').height cropBarHeight
      @$('.landsofillusions-components-overlay > .safe-area').css safeAreaSize
      
      # Inside the background the template in the else block can add a .max-area and .viewport-area divs for us to position.

      viewportAreaSize = viewport.viewportBounds.toDimensions()
      maxAreaSize = viewport.maxBounds.toDimensions()

      for area in [viewportAreaSize, maxAreaSize]
        area.top = Math.max area.top, cropBarHeight
        area.height = Math.min area.height, maxOverlayHeight

      @$('.viewport-area').css viewportAreaSize
      @$('.max-area').css maxAreaSize

      # Safe area can also appear inside viewport area.
      viewportAreaSafeAreaSize = viewport.safeArea.toDimensions()
      viewportAreaSafeAreaSize.top -= viewportAreaSize.top

      @$('.viewport-area .safe-area').css viewportAreaSafeAreaSize

    @$('.landsofillusions-components-overlay').addClass('visible')

    Meteor.setTimeout =>
      @$('.transition-cover')?.removeClass('visible')
    ,
      600

    @$('.crop-bar').height 0

    @$('.crop-bar').velocity
      height: [cropBarHeight, 0]
    ,
      duration: 200
      easing: 'easeOutQuint'

    # See if we're inside of a component with activatable state - if yes, we can listen to know when to deactivate.
    activatableParent = @ancestorComponentWith 'activatedState'

    if activatableParent
      @autorun (computation) =>
        activatedState = activatableParent.callFirstWith(null, 'activatedState')
        if activatedState is LOI.Adventure.Item.activatedStates.Deactivating
          # Animate out.
          @$('.landsofillusions-components-overlay').removeClass('visible')
          @$('.transition-cover').addClass('visible')

          @$('.crop-bar').velocity
            height: 0
          ,
            duration: 200
            delay: 300
            easing: 'easeInQuint'

  onDestroyed: ->
    super

    $('body').removeClass('overlay-disable-scrolling')
