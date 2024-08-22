FM = FataMorgana

class FM.Tool extends FM.Operator
  @icon: -> # Override to provide a URL to this tool's icon.
  icon: -> @constructor.icon()
  
  @pointerState =
    x: null
    y: null
    mainButton: false
    auxiliaryButton: false
    secondaryButton: false

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

  onPointerDown: (event) ->
    switch event.button
      when 0 then @constructor.pointerState.mainButton = true
      when 1 then @constructor.pointerState.auxiliaryButton = true
      when 2 then @constructor.pointerState.secondaryButton = true

  onPointerUp: (event) ->
    switch event.button
      when 0 then @constructor.pointerState.mainButton = false
      when 1 then @constructor.pointerState.auxiliaryButton = false
      when 2 then @constructor.pointerState.secondaryButton = false

  onPointerMove: (event) ->
    @constructor.pointerState.x = event.pageX
    @constructor.pointerState.y = event.pageY

  onPointerLeaveWindow: (event) ->
    # Just in case we clean up button state when leaving. Nowadays browsers
    # don't fire pointer leave when a button is pressed so it's not really necessary.
    @constructor.pointerState.mainButton = false
    @constructor.pointerState.auxiliaryButton = false
    @constructor.pointerState.secondaryButton = false
