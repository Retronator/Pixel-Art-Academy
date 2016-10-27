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

      backgroundSize = viewport.maxBounds.extrude -gapHeight, 0
      cropBarHeight = Math.max 0, backgroundSize.top()

      @$('.background').css backgroundSize.toDimensions()
      @$('.crop-bar').height cropBarHeight
      @$('.safe-area').css viewport.safeArea.toDimensions()

    # Animate in.
    @$('.lands-of-illusions-components-overlay').velocity
      opacity: [1, 0]
    ,
      duration: 500
