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
      cropBarHeight = Math.max 0, viewport.maxBounds.top + gapHeight

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
