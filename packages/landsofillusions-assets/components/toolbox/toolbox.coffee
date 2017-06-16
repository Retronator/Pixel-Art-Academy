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

    $(window).on 'keydown.landsofillusions-assets-components-toolbox', (event) => @onKeyDown event
    $(window).on 'keyup.landsofillusions-assets-components-toolbox', (event) => @onKeyUp event

  onDestroyed: ->
    super

    $(window).off '.landsofillusions-assets-components-toolbox'

  toolClass: ->
    tool = @currentData()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  activeToolClass: ->
    tool = @currentData()

    'active' if tool is @options.activeTool()

  events: ->
    super.concat
      'click .tool-button': @onClickToolButton

  onClickToolButton: (event) ->
    tool = @currentData()

    if tool.method
      tool.method()

    else
      @options.activeTool tool

  onKeyDown: (event) ->
    key = event.which

    # Find if the pressed key matches any of the tools' shortcuts.
    if targetTool = _.find(@options.tools(), (tool) => key is tool.shortcut)
      @options.activeTool targetTool

    # Look if it matches the hold shortcut.
    if targetTool = _.find(@options.tools(), (tool) => key is tool.holdShortcut)
      # Store currently active tool before switching the tools.
      @_storedTool @options.activeTool()
      @options.activeTool targetTool

  onKeyUp: (event) ->
    # Restore the stored tool.
    if storedTool = @_storedTool()
      @options.activeTool storedTool
      @_storedTool null
