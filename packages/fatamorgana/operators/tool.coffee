FM = FataMorgana

class FM.Tool extends FM.Operator
  @icon: -> # Override to provide a URL to this tool's icon.
  icon: -> @constructor.icon()

  constructor: ->
    super arguments...
    
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
    @mouseState.x = event.pageX
    @mouseState.y = event.pageY

  onMouseLeaveWindow: (event) ->
    # Just in case we clean up button state when leaving. Nowadays browsers
    # don't fire mouse leave when a button is pressed so it's not really necessary.
    @mouseState.leftButton = false
    @mouseState.middleButton = false
    @mouseState.rightButton = false
