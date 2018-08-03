AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Text extends LOI.Interface.Text
  resize: (options = {}) ->
    return unless situation = LOI.adventure.currentSituation()

    viewport = @display.viewport()
    scale = @display.scale()

    gridSpacing = 8 * scale
    sideMargin = gridSpacing
    lineHeight = gridSpacing

    illustrationHeight = (situation.illustrationHeight.last() or 0) * scale

    $textInterface = $('.landsofillusions-adventure .landsofillusions-interface-text')
    $ui = $textInterface.find('.ui')
    $uiBackground = $textInterface.find('.ui-background')

    # Resize location.
    locationSize = new AE.Rectangle
      x: viewport.viewportBounds.x()
      y: viewport.viewportBounds.y()
      width: viewport.viewportBounds.width()
      height: illustrationHeight

    $textInterface.find('.location').eq(0).css(locationSize.toDimensions())

    # Resize user interface. We make sure the UI has at least the side margin, but make the inner content align with
    # location illustration if possible. We do that by seeing if we have empty room left/right from the viewport.
    totalWidth = viewport.viewportBounds.width() + viewport.viewportBounds.x() * 2

    # The UI content would be aligned if it's bigger, since that'll be compensated by the margin.
    uiWidth = viewport.viewportBounds.width() + 2 * sideMargin

    # However, make sure that it fits in the window (total width).
    uiWidth = Math.min uiWidth, totalWidth

    # For UI height, we fill the rest of the viewport that the location isn't using it.
    fillUIHeight = viewport.viewportBounds.height() - locationSize.height() - lineHeight

    # Make sure that UI fills at least half the screen, if it needs to.
    totalContentHeight = $textInterface.find('.text-display-content').height()
    neededUIHeight = Math.min totalContentHeight, viewport.viewportBounds.height() / 2

    uiHeight = Math.max neededUIHeight, fillUIHeight

    # Make it a multiple of line height.
    uiHeight = Math.floor(uiHeight / lineHeight) * lineHeight

    # If not all content has been accommodated, remove a pixel since it otherwise bleeds at the top.
    uiHeight -= 1 if uiHeight < totalContentHeight

    uiSize = new AE.Rectangle
      x: viewport.viewportBounds.x() + viewport.viewportBounds.width() / 2 - uiWidth / 2
      y: locationSize.bottom() + lineHeight
      width: uiWidth
      height: uiHeight

    # Put double the side margin gap between text display and interface and side margin
    # on the outside (total 4 times the side margin). After that split them 70:30.
    textDisplaySize = new AE.Rectangle
      x: sideMargin
      y: 0
      width: (uiWidth - 4 * sideMargin) * 0.7
      height: uiHeight

    sidebarWidth = (uiWidth - 4 * sideMargin) * 0.3
    inventorySize = new AE.Rectangle
      x: textDisplaySize.right() + 2 * sideMargin
      y: 0
      width: sidebarWidth
      height: uiHeight

    # Calculate minimap size for use by the Map item. It's relative to the viewport, not the UI.
    @minimapSize new AE.Rectangle
      x: inventorySize.left() + uiSize.x()
      y: viewport.viewportBounds.height() - sidebarWidth - 2 * lineHeight
      width: sidebarWidth
      height: sidebarWidth

    # Apply UI dimensions.
    $ui.css uiSize.toDimensions()

    # Background adds an extra line border around the UI
    uiBackgroundSize = uiSize.extrude lineHeight
    $uiBackground.css(uiBackgroundSize.toDimensions())

    $ui.find('.text-display').css(textDisplaySize.toDimensions()).height('100%')
    $ui.find('.text-display-content').width(textDisplaySize.width())

    $ui.find('.inventory').css(inventorySize.toDimensions()).height('100%')
    $ui.find('.inventory-content').width(inventorySize.width())

    # Set total interface height so that scrolling can use it in its calculations.
    $textInterface.find('.ui-area').add('body').height uiSize.bottom()

    # Let the text interface handle its scrolling areas.
    @clampScrollableAreas()

  animateElement: (options) ->
    options.duration ?= 150
    options.animate ?= true
    options.easing ?= 'ease-out'

    # Cancel any previous animation.
    options.$element.velocity('stop')

    if options.animate
      options.$element.velocity options.properties,
        duration: options.duration
        easing: options.easing
        complete: options.complete
        progress: options.progress

    else
      for name, value of options.properties
        $.Velocity.hook options.$element, name, value

      options.complete?()
