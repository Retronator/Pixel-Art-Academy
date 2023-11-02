FM = FataMorgana

class FM.Tool extends FM.Operator
  @icon: -> # Override to provide a URL to this tool's icon.
  icon: -> @constructor.icon()
  
  @mouseState =
    x: null
    y: null
    leftButton: false
    middleButton: false
    rightButton: false

  extraToolClasses: -> '' # Override to provide extra style classes to be used besides its display name.
  
  toolClasses: ->
    toolClass = _.kebabCase @displayName()
    
    "#{toolClass} #{@extraToolClasses()}"
    
  isActive: ->
    @interface.active() and @interface.activeToolId() is @id()

  onKeyDown: (event) ->
    # Override to handle key presses.

  onKeyUp: (event) ->
    # Override to handle key releases.

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
    @constructor.mouseState.x = event.pageX
    @constructor.mouseState.y = event.pageY

  onMouseLeaveWindow: (event) ->
    # Just in case we clean up button state when leaving. Nowadays browsers
    # don't fire mouse leave when a button is pressed so it's not really necessary.
    @constructor.mouseState.leftButton = false
    @constructor.mouseState.middleButton = false
    @constructor.mouseState.rightButton = false
