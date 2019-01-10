AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Toolbox extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.Toolbox'

  constructor: (@options) ->
    super arguments...

    @_storedTool = new ReactiveField null

  onRendered: ->
    super arguments...

    $(document).on 'keydown.landsofillusions-assets-components-toolbox', (event) => @onKeyDown event
    $(document).on 'keyup.landsofillusions-assets-components-toolbox', (event) => @onKeyUp event

  onDestroyed: ->
    super arguments...

    $(document).off '.landsofillusions-assets-components-toolbox'

  toolClass: ->
    tool = @currentData()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  activeToolClass: ->
    tool = @currentData()

    'active' if tool is @options.activeTool()

  activateTool: (tool, storePreviousTool) ->
    if tool.method
      tool.method()

    else
      previousActiveTool = @options.activeTool()
      return if tool is previousActiveTool

      @_storedTool previousActiveTool if storePreviousTool

      # Set tool as active.
      @options.activeTool tool

      # Inform the tools that they (de)activated.
      previousActiveTool?.onDeactivated?()
      tool.onActivated?()

  deactivateTool: ->
    return unless activeTool = @options.activeTool()
    @options.activeTool null
    activeTool.onDeactivated?()

  events: ->
    super(arguments...).concat
      'click .tool-button': @onClickToolButton

  onClickToolButton: (event) ->
    tool = @currentData()
    @activateTool tool

  onKeyDown: (event) ->
    # Check if the toolbox is enabled.
    return if @options.enabled? and not @options.enabled()

    key = event.which

    # TODO: Figure out when to prevent key repeating. It's not always desirable (undo/redo).
    # return if key is @_activeKey

    # Find if the pressed key matches any of the tools' shortcuts.
    keyboardState = AC.Keyboard.getState()
    commandOrCtrlDown = keyboardState.isCommandOrCtrlDown()
    shiftDown = keyboardState.isKeyDown AC.Keys.shift

    targetTool = _.find @options.tools(), (tool) =>
      _.every [
        key is tool.shortcut
        shiftDown is tool.shortcutShift
        commandOrCtrlDown is tool.shortcutCommandOrCtrl
      ]

    if targetTool
      @activateTool targetTool

      # Prevent browser shortcuts from firing.
      event.preventDefault()
      
      # Prevent other in-game key listeners to also fire.
      event.stopImmediatePropagation()

    # Look if it matches the hold shortcut.
    if targetTool = _.find(@options.tools(), (tool) => key is tool.holdShortcut)
      # Store currently active tool before switching the tools.
      @activateTool targetTool, true
      event.preventDefault()

    @_activeKey = key

  onKeyUp: (event) ->
    # Check if the toolbox is enabled.
    return if @options.enabled? and not @options.enabled()

    # Restore the stored tool.
    if storedTool = @_storedTool()
      @activateTool storedTool
      @_storedTool null

    @_activeKey = null
