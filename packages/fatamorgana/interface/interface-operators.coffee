AC = Artificial.Control
FM = FataMorgana

class FM.Interface extends FM.Interface
  @register 'FataMorgana.Interface'

  constructor: ->
    super arguments...

    @_operatorInstances = {}

  onCreated: ->
    super arguments...

    @activeTool = new ComputedField =>
      @getOperator @activeToolId()

    @storedTool = new ReactiveField null

    @operators = new ComputedField =>
      operatorIds = FM.Operator.getIds()
      currentOperatorIds = @_collectOperatorIds @currentLayoutData().value(), operatorIds

      @_getOperatorInstance operatorId for operatorId in currentOperatorIds

    @actions = new ComputedField => _.filter @operators(), (operator) => operator instanceof FM.Action
    @tools = new ComputedField => _.filter @operators(), (operator) => operator instanceof FM.Tool

    # Notify the initial tool that it has activated.
    @activeTool()?.onActivated?()

  _getOperatorInstance: (operatorId) ->
    unless @_operatorInstances[operatorId]
      operatorClass = FM.Operator.getClassForId operatorId
      @_operatorInstances[operatorId] = Tracker.nonreactive => new operatorClass @

    @_operatorInstances[operatorId]

  _collectOperatorIds: (source, possibleValues) ->
    if _.isString source
      # See if the string is one of the possible values.
      if source in possibleValues
        return [source]

    else if _.isArray source
      # Iterate over all array items.
      return _.flatten (@_collectOperatorIds item, possibleValues for item in source)

    else if _.isObject source
      # Iterate over all properties.
      return _.flatten (@_collectOperatorIds value, possibleValues for key, value of source)

    # We couldn't find any IDs.
    []

  onRendered: ->
    super arguments...

    $(document).on 'keydown.fatamorgana-interface', (event) => @onKeyDown event
    $(document).on 'keyup.fatamorgana-interface', (event) => @onKeyUp event
    $(document).on 'pointerdown.fatamorgana-interface', (event) => @onPointerDown event
    $(document).on 'pointerup.fatamorgana-interface', (event) => @onPointerUp event
    $(document).on 'pointerleave.fatamorgana-interface', (event) => @onPointerLeaveWindow event

  onDestroyed: ->
    super arguments...
    
    operator.destroy() for operatorId, operator of @_operatorInstances

    $(document).off '.fatamorgana-interface'

  getOperator: (operatorClassOrId) ->
    return unless operatorId = operatorClassOrId?.id?() or operatorClassOrId
    @_getOperatorInstance operatorId

  getShortcutForOperator: (operatorClassOrId) ->
    operatorId = operatorClassOrId.id?() or operatorClassOrId
    @currentShortcutsMapping()[operatorId]

  activateTool: (tool, storePreviousTool) ->
    previousActiveTool = @activeTool?()
    return if tool is previousActiveTool

    @storedTool previousActiveTool if storePreviousTool

    # Set tool as active.
    @activeToolId tool.id()

    # Inform the tools that they (de)activated.
    previousActiveTool?.onDeactivated?()
    tool.onActivated?()

  deactivateTool: ->
    return unless activeTool = @activeTool()
    @activeToolId null unless @restoreStoredTool()
    activeTool.onDeactivated?()
    
  restoreStoredTool: ->
    if storedTool = @storedTool()
      @activateTool storedTool
      @storedTool null
      return true
      
    false

  shortcutsActive: ->
    # Make sure we're not currently typing into an input.
    not @inputFocused()

  onKeyDown: (event) ->
    return unless @active()
    
    @activeTool()?.onKeyDown? event
    
    @onInputDown event, AC.Keyboard
  
  onPointerDown: (event) ->
    return unless @active()
    
    # Ignore touch events.
    return if event.pointerType is 'touch'
    
    @activeTool()?.onPointerDown? event
    
    @onInputDown event, AC.Pointer

  onInputDown: (event, inputClass) ->
    return unless @shortcutsActive()

    # TODO: Figure out when to prevent key repeating. It's not always desirable (undo/redo).

    # Find if the pressed key matches any of the tools' shortcuts.
    targetTool = _.find @tools(), (tool) => inputClass.isShortcutDown event, @getShortcutForOperator tool
    targetAction = _.find @actions(), (action) => inputClass.isShortcutDown event, @getShortcutForOperator action

    if targetTool
      # We want to store the previous tool if we're activating this tool with the hold key.
      targetToolShortcut = @getShortcutForOperator targetTool
      
      isHoldShortcutActive = (shortcut) =>
        return true if event.keyCode and event.keyCode is shortcut.holdKey
        return true if event.button and event.button is shortcut.holdButton
        false

      if _.isArray targetToolShortcut
        storePreviousTool = _.find targetToolShortcut, isHoldShortcutActive

      else
        storePreviousTool = isHoldShortcutActive targetToolShortcut

      if storePreviousTool
        @_holdKey = event.keyCode
        @_holdButton = event.button

      @activateTool targetTool, storePreviousTool
      
    if targetAction?.enabled()
      targetAction.execute()

    if targetTool or targetAction
      # Prevent browser shortcuts from firing.
      event.preventDefault()
      
      # Prevent other in-game key listeners to also fire.
      event.stopImmediatePropagation()

  onKeyUp: (event) ->
    return unless @active()

    @activeTool()?.onKeyUp? event
    
    @onInputUp event
    
  onPointerUp: (event) ->
    return unless @active()
    
    # Ignore touch events.
    return if event.pointerType is 'touch'
    
    @activeTool()?.onPointerUp? event
    
    @onInputUp event
    
  onInputUp: (event) ->
    return unless @shortcutsActive()
    return unless @_holdKey is event.keyCode or @_holdButton is event.button

    @restoreStoredTool()

    @_holdKey = null
    @_holdButton = null
  
  onPointerLeaveWindow: (event) ->
    return unless @active()
    
    @activeTool()?.onPointerLeaveWindow? event
