LOI = LandsOfIllusions

class LOI.Assets.Components.Tool
  constructor: (@options) ->
    @mouseState =
      x: null
      y: null
      leftButton: false
      middleButton: false
      rightButton: false

  onMouseDown: (event) ->
    switch event.which
      when 1 then @mouseState.leftButton = true
      when 2 then @mouseState.middleButton = true
      when 3 then @mouseState.rightButton = true

  onMouseUp: (event) ->
    switch event.which
      when 1 then @mouseState.leftButton = false
      when 2 then @mouseState.middleButton = false
      when 3 then @mouseState.rightButton = false

  onMouseMove: (event) ->
    return unless pixelCoordinate = @options.editor().pixelCanvas().mouse().pixelCoordinate()

    @mouseState.x = pixelCoordinate.x
    @mouseState.y = pixelCoordinate.y

  onMouseLeaveWindow: (event) ->
    # Just in case we clean up button state when leaving. Nowadays browsers
    # don't fire mouse leave when a button is pressed so it's not really necessary.
    @mouseState.leftButton = false
    @mouseState.middleButton = false
    @mouseState.rightButton = false
