AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Text.Resizing
  constructor: (@textInterface) ->
    @textInterface.autorun =>
      # Register dependency on display scaling and viewport size.
      scale = @textInterface.display.scale()
      gridSpacing = 8 * scale
      sideMargin = gridSpacing
      lineHeight = gridSpacing

      viewport = @textInterface.display.viewport()

      # Figure out if reactivity was triggered due to resize (viewport or scale change) or lines count.
      linesChanged = @textInterface._previousLineCount isnt @textInterface.narrative.linesCount()
      resized = not linesChanged

      @textInterface._previousLineCount = @textInterface.narrative.linesCount()

      $textInterface = $('.adventure .text-interface')
      $ui = $textInterface.find('.ui')

      location = @textInterface.adventure.currentLocation()
      illustrationHeight = (location?.illustrationHeight() or 0) * scale

      if resized
        # Resize location.
        locationSize = new AE.Rectangle
          x: viewport.viewportBounds.x()
          y: viewport.viewportBounds.y()
          width: viewport.viewportBounds.width()
          height: illustrationHeight

        $textInterface.find('.location').css(locationSize.toDimensions())

        # Resize user interface. We make sure the UI has at least the side margin, but make the inner content align with
        # location illustration if possible. We do that by seeing if we have empty room left/right from the viewport.
        totalWidth = viewport.viewportBounds.width() + viewport.viewportBounds.x() * 2

        # The UI content would be aligned if it's bigger, since that'll be compensated by the margin.
        uiWidth = viewport.viewportBounds.width() + 2 * sideMargin * scale

        # However, make sure that it fits in the window (total width).
        uiWidth = Math.min uiWidth, totalWidth

        # UI height fills the rest.
        uiHeight = viewport.viewportBounds.height() - locationSize.height()

        # But make it a multiple of line height and add one line for border.
        uiHeight = Math.max 0, Math.floor(uiHeight / lineHeight - 1) * lineHeight

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

        inventorySize = new AE.Rectangle
          x: textDisplaySize.right() + 2 * sideMargin
          y: 0
          width: (uiWidth - 4 * sideMargin) * 0.3
          height: uiHeight

        $ui.css(uiSize.toDimensions())

        $textInterface.find('.text-display').css(textDisplaySize.toDimensions()).height('100%')
        $textInterface.find('.text-display-content').width(textDisplaySize.width())

        $textInterface.find('.inventory').css(inventorySize.toDimensions()).height('100%')
        $textInterface.find('.inventory-content').width(inventorySize.width())

      # Wait until text has re-flown due to resizing.
      Tracker.afterFlush =>
        # If lines have changed, animate addition of new content.
        animate = linesChanged

        uiHeight = $ui.height()
        totalContentHeight = $textInterface.find('.text-display-content').height()

        if totalContentHeight > uiHeight
          # We want to show as much of narrative as possible so potentially make the location illustration smaller, but no
          # less than half the viewport (unless the illustration itself is smaller than that). What's left is the place for
          # the UI, plus one line border at the top. The new UI height must fit into this space or less.
          viewportHeight = viewport.viewportBounds.height()

          minimumIllustrationHeight = Math.min(illustrationHeight, viewportHeight / 2)

          maxDisplayedContentHeight = viewportHeight - minimumIllustrationHeight - lineHeight
          newUIHeight = Math.min maxDisplayedContentHeight, totalContentHeight

          # Make the UI a multiple of line height.
          newUIHeight = Math.max 0, Math.floor(newUIHeight / lineHeight) * lineHeight

          # Location fills in the rest that's not taken up by text display plus one line border.
          locationHeight = Math.min illustrationHeight, viewportHeight - newUIHeight - lineHeight
          @_animateElement $textInterface.find('.location'), animate, height: locationHeight

          # Put UI below the location with 1 line margin.
          @_animateElement $ui, animate,
            top: locationHeight + lineHeight
            height: newUIHeight

          # Scroll to bottom on resizes.
          @textInterface.narrative.scroll
            animate: animate
            height: newUIHeight

  _animateElement: ($element, animate, properties) ->
    if animate
      $element.velocity('stop').velocity properties,
        duration: 150
        easing: 'ease-out'

    else
      $element.css properties
