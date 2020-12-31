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

    @_storedTool = new ReactiveField null

    @operators = new ComputedField =>
      operatorIds = FM.Operator.getIds()
      currentOperatorIds = @_collectOperatorIds @currentApplicationAreaData().value(), operatorIds

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

  onDestroyed: ->
    super arguments...

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

    @_storedTool previousActiveTool if storePreviousTool

    # Set tool as active.
    @activeToolId tool.id()

    # Inform the tools that they (de)activated.
    previousActiveTool?.onDeactivated?()
    tool.onActivated?()

  deactivateTool: ->
    return unless activeTool = @activeTool()
    @activeToolId null
    activeTool.onDeactivated?()

  shortcutsActive: ->
    # Make sure we're not currently typing into an input.
    not @inputFocused()

  onKeyDown: (event) ->
    @activeTool()?.onKeyDown? event
    
    return unless @shortcutsActive()

    key = event.which

    # TODO: Figure out when to prevent key repeating. It's not always desirable (undo/redo).
    # return if key is @_activeKey

    # Find if the pressed key matches any of the tools' shortcuts.
    keyboardState = AC.Keyboard.getState()

    targetTool = _.find @tools(), (tool) => keyboardState.isShortcutDown @getShortcutForOperator tool
    targetAction = _.find @actions(), (action) => keyboardState.isShortcutDown @getShortcutForOperator action

    if targetTool
      # We want to store the previous tool if we're activating this tool with the hold key.
      targetToolShortcut = @getShortcutForOperator targetTool

      if _.isArray targetToolShortcut
        storePreviousTool = _.find targetToolShortcut, (shortcut) => shortcut.holdKey

      else
        storePreviousTool = key is targetToolShortcut.holdKey

      @activateTool targetTool, storePreviousTool
      
    if targetAction?.enabled()
      targetAction.execute()

    if targetTool or targetAction
      # Prevent browser shortcuts from firing.
      event.preventDefault()
      
      # Prevent other in-game key listeners to also fire.
      event.stopImmediatePropagation()

    @_activeKey = key

  onKeyUp: (event) ->
    @activeTool()?.onKeyUp? event

    return unless @shortcutsActive()

    # Restore the stored tool.
    if storedTool = @_storedTool()
      @activateTool storedTool
      @_storedTool null

    @_activeKey = null
