LOI = LandsOfIllusions

class LOI.Assets.Components.Tools.Tool
  @mouseState =
    x: null
    y: null
    leftButton: false
    middleButton: false
    rightButton: false
    
  constructor: (@options) ->

  onMouseDown: (event) ->
    switch event.which
      when 1 then @constructor.mouseState.leftButton = true
      when 2 then @constructor.mouseState.middleButton = true
      when 3 then @constructor.mouseState.rightButton = true

  onMouseUp: (event) ->
    switch event.which
      when 1 then @constructor.mouseState.leftButton = false
      when 2 then @constructor.mouseState.middleButton = false
      when 3 then @constructor.mouseState.rightButton = false

  onMouseMove: (event) ->
    return unless pixelCoordinate = @options.editor().pixelCanvas().mouse().pixelCoordinate()

    @constructor.mouseState.x = pixelCoordinate.x
    @constructor.mouseState.y = pixelCoordinate.y

  onMouseLeaveWindow: (event) ->
    # Just in case we clean up button state when leaving. Nowadays browsers
    # don't fire mouse leave when a button is pressed so it's not really necessary.
    @constructor.mouseState.leftButton = false
    @constructor.mouseState.middleButton = false
    @constructor.mouseState.rightButton = false
