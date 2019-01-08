AB = Artificial.Base
AM = Artificial.Mirage
FM = FataMorgana

class FM.Interface extends AM.Component
  # activeToolId: the tool that the user is currently using to perform operations
  # activeFileId: identifying data for the file that is currently the target of operations
  # components: map of all terminal singleton components
  #   {component_id}: data for the content component
  # files: map of all file states (local to the editor, unlike editor preferences potentially stored in the file itself)
  #   {fileId}: data for the file
  # componentsForFiles: map of all component states that differ per file
  #   {fileId}
  #     {component_id}: state for the component/file combination
  # layouts
  #   currentLayoutId: currently active layout, if not specified in the URL
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
  # shortcuts
  #   currentMappingId: the mapping currently active
  #   {mappingId}:
  #     name: name of the mapping
  #     mapping: an object of assigned shortcuts
  #       {operatorId}: shortcut definition for this operator
  #         key: the main key that needs to be pressed
  #         holdKey: the key that temporarily switches to the operator while pressed
  #         commandOrControl: wildcard for either command or control modifier
  #         command, win, super: require the meta key modifier
  #         control: require the control key modifier
  #         alt: require the alt key modifier
  #         shift: requires the shift key modifier
  constructor: (@parent, @options) ->
    super arguments...
    
    @inputFocused = new ReactiveField false

  onCreated: ->
    super arguments...

    @data = new @constructor.Data @options

    @activeToolId = @data.child('activeToolId').value
    @activeFileId = @data.child('activeFileId').value

    @currentLayoutId = new ComputedField =>
      AB.Router.currentRouteData().searchParameters.get('layout') or @data.child('layouts.currentLayoutId').value()
      
    @currentLayoutData = new ComputedField =>
      @data.child "layouts.#{@currentLayoutId()}"
      
    @currentApplicationAreaData = new ComputedField =>
      @currentLayoutData().child 'applicationArea'

    @currentShortcutsMappingId = @data.child('shortcuts.currentMappingId').value

    @currentShortcutsMapping = new ComputedField =>
      @data.child("shortcuts.#{@currentShortcutsMappingId()}.mapping").value()

    @componentsData = @data.child 'components'
    @filesData = @data.child 'files'
    @componentsForFilesData = @data.child 'componentsForFiles'

    @dialogs = new ReactiveField []
    
    @_helperInstances = {}

  onDestroyed: ->
    super arguments...

    @data.destroy()

  getComponentData: (componentClassOrId) ->
    componentId = _.snakeCase componentClassOrId.id?() or componentClassOrId
    @componentsData.child componentId

  getFileData: (fileId) ->
    @filesData.child fileId

  getComponentDataForFile: (componentClassOrId, fileId) ->
    componentId = _.snakeCase componentClassOrId.id?() or componentClassOrId

    @componentsForFilesData.child "#{fileId}.#{componentId}"

  getComponentDataForActiveFile: (componentClassOrId) ->
    return unless fileId = @activeFileId()

    @getComponentDataForFile componentClassOrId, fileId

  activateFile: (fileId) ->
    @activeFileId fileId

  getEditorForActiveFile: ->
    activeFileId = @activeFileId()

    # Get all the editor views.
    editorViews = @allChildComponentsOfType FM.EditorView

    # Search for the editor view that is showing the active file.
    for editorView in editorViews
      continue unless files = editorView.data().get('files')

      if _.find files, (file) => file.id is activeFileId and file.active
        return editorView.getActiveEditor()

    null
    
  getHelper: (helperClassOrId) ->
    helperId = helperClassOrId.id?() or helperClassOrId

    # Create the helper singleton on first request.
    @_helperInstances[helperId] ?= Tracker.nonreactive =>
      helperClass = FM.Operator.getClassForId helperId
      @_helperInstances[helperId] = new helperClass @

    @_helperInstances[helperId]
  
  displayDialog: (dialog) ->
    # Wrap the plain object into data for compatibility.
    dialogData = new FM.Interface.Data load: => dialog

    # Add ID to minimize reactivity.
    dialogData._id ?= Random.id()

    dialogs = @dialogs()
    dialogs.push dialogData
    @dialogs dialogs

  closeDialog: (dialog) ->
    dialogs = @dialogs()
    _.pull dialogs, dialog
    @dialogs dialogs

  windows: ->
    windowsData = @currentLayoutData().child 'windows'
    return unless windows = _.cloneDeep windowsData.value()

    _.orderBy windows, 'order'

    # Create child data objects to send as data.
    for window, index in windows
      childData = windowsData.child index
      childData._id = index
      childData

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
    return unless dialog.value().canDismiss

    # We only want to react to clicks directly on the dialog area.
    return unless $(event.target).hasClass('dialog-area')

    @closeDialog dialog

  onFocusInput: (event) ->
    @inputFocused true

  onBlurInput: (event) ->
    @inputFocused false
