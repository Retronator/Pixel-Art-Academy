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

  toolClass: ->
    tool = @currentData()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  activeToolClass: ->
    tool = @currentData()

    'active' if tool is @interface.activeTool()

  events: ->
    super(arguments...).concat
      'click .tool-button': @onClickToolButton

  onClickToolButton: (event) ->
    tool = @currentData()
    @interface.activateTool tool
