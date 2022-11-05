AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana

class FM.Toolbox extends FM.View
  # tools: array of tools in the toolbox
  #   [toolId]: string identifying the tool
  @id: -> 'FataMorgana.Toolbox'
  @register @id()

  tool: ->
    toolId = @currentData()
    @interface.getOperator toolId

  activeToolClass: ->
    tool = @currentData()

    'active' if tool is @interface.activeTool()

  tooltip: ->
    tool = @currentData()
    name = tool.displayName()
    shortcut = tool.currentShortcut()
    return name unless shortcut

    shortcut = shortcut[0] if _.isArray shortcut
    shortcut = AM.ShortcutHelper.getShortcutString shortcut

    "#{name} (#{shortcut})"

  events: ->
    super(arguments...).concat
      'click .tool-button': @onClickToolButton

  onClickToolButton: (event) ->
    tool = @currentData()
    @interface.activateTool tool
