AC = Artificial.Control
FM = FataMorgana

class FM.Interface extends FM.Interface
  constructor: ->
    super arguments...

    @_storedTool = new ReactiveField null

  onRendered: ->
    super arguments...

    $(document).on 'keydown.fatamorgana-interface', (event) => @onKeyDown event
    $(document).on 'keyup.fatamorgana-interface', (event) => @onKeyUp event

  onDestroyed: ->
    super arguments...

    $(document).off '.fatamorgana-interface'

  activateTool: (tool, storePreviousTool) ->
    previousActiveTool = @activeTool()
    return if tool is previousActiveTool

    @_storedTool previousActiveTool if storePreviousTool

    # Set tool as active.
    @activeTool tool

    # Inform the tools that they (de)activated.
    previousActiveTool?.onDeactivated?()
    tool.onActivated?()

  deactivateTool: ->
    return unless activeTool = @activeTool()
    @activeTool null
    activeTool.onDeactivated?()

  shortcutsActive: ->
    # Make sure we're not currently typing into an input.
    @inputFocused()

  onKeyDown: (event) ->
    return unless @shortcutsActive()

    key = event.which

    # TODO: Figure out when to prevent key repeating. It's not always desirable (undo/redo).
    # return if key is @_activeKey

    # Find if the pressed key matches any of the tools' shortcuts.
    keyboardState = AC.Keyboard.getState()
    tools = @getTools()
    actions = @getActions()

    targetTool = _.find tools, (tool) => keyboardState.isShortcutDown tool.shortcut
    targetAction = _.find actions, (action) => keyboardState.isShortcutDown action.shortcut

    if targetTool
      # We want to store the previous tool if we're activating this tool with the hold key.
      storePreviousTool = key is targetTool.shortcut.holdKey
      @activateTool targetTool, storePreviousTool
      
    if targetAction
      targetAction.execute()

    if targetTool or targetAction
      # Prevent browser shortcuts from firing.
      event.preventDefault()
      
      # Prevent other in-game key listeners to also fire.
      event.stopImmediatePropagation()

    @_activeKey = key

  onKeyUp: (event) ->
    return unless @shortcutsActive()

    # Restore the stored tool.
    if storedTool = @_storedTool()
      @activateTool storedTool
      @_storedTool null

    @_activeKey = null
