AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Overlay extends AM.Component
  @register 'LandsOfIllusions.Components.Overlay'

  onRendered: ->
    cropBarHeight = 0

    # Resize elements.
    @autorun (computation) =>
      adventure = @ancestorComponent LOI.Adventure

      scale = adventure.interface.display.scale()
      viewport = adventure.interface.display.viewport()

      # Background can be at most 360px * scale high. Crop bars need to fill the rest when overlay is active.
      maxOverlayHeight = 360 * scale
      maxBoundsHeight = viewport.maxBounds.height()
      gapHeight = (maxBoundsHeight - maxOverlayHeight) / 2
      cropBarHeight = Math.max 0, viewport.maxBounds.top() + gapHeight

      safeAreaSize = viewport.safeArea.toDimensions()
      safeAreaSize.left += viewport.viewportBounds.left()
      safeAreaSize.top += viewport.viewportBounds.top()

      @$('.crop-bar').height cropBarHeight
      @$('.safe-area').css safeAreaSize

    # Animate in.
    @$('.background').velocity
      opacity: [1, 0]
    ,
      duration: 500

    @$('.safe-area').velocity
      opacity: [1, 0]
    ,
      duration: 500

    @$('.crop-bar').velocity
      height: [cropBarHeight, 0]
    ,
      duration: 200
      easing: 'easeOutQuint'

    # See if we're inside of an item - if yes, we can listen to know when to deactivate.
    itemParent = @ancestorComponentWith (component) =>
      component instanceof LOI.Adventure.Item

    if itemParent
      @autorun (computation) =>
        if itemParent.activatedState() is LOI.Adventure.Item.activatedStates.Deactivating
          # Animate out.
          @$('.background').velocity
            opacity: 0
          ,
            duration: 500

          @$('.safe-area').velocity
            opacity: 0
          ,
            duration: 500

          @$('.crop-bar').velocity
            height: 0
          ,
            duration: 200
            delay: 300
            easing: 'easeInQuint'
