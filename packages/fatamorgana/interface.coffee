AB = Artificial.Base
AM = Artificial.Mirage
FM = FataMorgana

class FM.Interface extends AM.Component
  # contentComponents: object of all terminal components
  #   {componentId}: data for the content component
  # layouts
  #   {layoutId}:
  #     name: name of the layout
  #     applicationArea: hierarchy of docked areas
  #       type: type of the layout area
  #       content
  #         type
  #           ...
  #       ...
  #     windows: array of floating windows
  #       order: the ordering of the floating area
  #       contentComponentId: ID of the content component
  @register 'FataMorgana.Interface'

  constructor: (@options) ->
    super arguments...

    @contentComponents = new ReactiveField {}
    @actions = new ReactiveField {}
    @tools = new ReactiveField {}

    @activeTool = new ReactiveField null

    @inputFocused = new ReactiveField true

  onCreated: ->
    super arguments...
    
    @currentLayoutId = new ComputedField =>
      AB.Router.currentRouteData().searchParameters.get('layout') or @options.defaultLayoutId
      
    @currentLayout = new ComputedField =>
      @options.data()?.layouts[@currentLayoutId()]
      
    @dialogs = new ReactiveField []

  registerContentComponent: (contentComponent) ->
    contentComponents = @contentComponents()
    contentComponents[contentComponent.constructor.id()] = contentComponent
    @contentComponents contentComponents

  registerAction: (action) ->
    actions = @actions()
    actions[action.id()] = action
    @actions actions

  getActions: ->
    _.values @actions()

  registerTool: (tool) ->
    tools = @tools()
    tools[tool.id()] = tool
    @tools tools
    
  getTool: (toolClassOrId) ->
    toolId = toolClassOrId.id?() or toolClassOrId
    @tools()[toolId]
    
  getTools: ->
    _.values @tools()

  saveData: ->
    @options.save()
    
  displayDialog: (dialog) ->
    # Add ID to minimize reactivity.
    dialog._id ?= Random.id()

    dialogs = @dialogs()
    dialogs.push dialog
    @dialogs dialogs

  closeDialog: (dialog) ->
    dialogs = @dialogs()
    _.pull dialogs, dialog
    @dialogs dialogs

  applicationAreaData: ->
    @currentLayout().applicationArea

  windows: ->
    return unless windows = _.cloneDeep @currentLayout().windows
    
    window._id = window.contentComponentId for window in windows
      
    _.orderBy windows, 'order'

  toolClass: ->
    return unless tool = @activeTool()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  events: ->
    super(arguments...).concat
      'click .dialog-area': @onClickDialogArea
      'focus input': @onFocusInput
      'blur input': @onBlurInput

  onClickDialogArea: (event) ->
    dialog = @currentData()

    # The user needs to be able to dismiss the dialog by clicking outside the dialog.
    return unless dialog.canDismiss

    # We only want to react to clicks directly on the dialog area.
    return unless $(event.target).hasClass('dialog-area')

    @closeDialog dialog

  onFocusInput: (event) ->
    @inputFocused true

  onBlurInput: (event) ->
    @inputFocused false
