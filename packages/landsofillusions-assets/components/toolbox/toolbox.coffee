AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Toolbox extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.Toolbox'

  constructor: (@options) ->
    super

    @_storedTool = new ReactiveField null

  onRendered: ->
    super

    $(document).on 'keydown.landsofillusions-assets-components-toolbox', (event) => @onKeyDown event
    $(document).on 'keyup.landsofillusions-assets-components-toolbox', (event) => @onKeyUp event

  onDestroyed: ->
    super

    $(document).off '.landsofillusions-assets-components-toolbox'

  toolClass: ->
    tool = @currentData()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  activeToolClass: ->
    tool = @currentData()

    'active' if tool is @options.activeTool()

  activateTool: (tool) ->
    if tool.method
      tool.method()

    else
      previousActiveTool = @options.activeTool()
      return if tool is previousActiveTool

      # Set tool as active.
      @options.activeTool tool

      # Inform the tools that they (de)activated.
      previousActiveTool?.onDeactivated?()
      tool.onActivated?()

  events: ->
    super.concat
      'click .tool-button': @onClickToolButton

  onClickToolButton: (event) ->
    tool = @currentData()
    @activateTool tool

  onKeyDown: (event) ->
    key = event.which

    # Prevent key repeating.
    return if key is @_activeKey

    # Find if the pressed key matches any of the tools' shortcuts.
    if targetTool = _.find(@options.tools(), (tool) => key is tool.shortcut)
      @activateTool targetTool

    # Look if it matches the hold shortcut.
    if targetTool = _.find(@options.tools(), (tool) => key is tool.holdShortcut)
      # Store currently active tool before switching the tools.
      @_storedTool @options.activeTool()
      @activateTool targetTool

    @_activeKey = key

  onKeyUp: (event) ->
    # Restore the stored tool.
    if storedTool = @_storedTool()
      @activateTool storedTool
      @_storedTool null

    @_activeKey = null
