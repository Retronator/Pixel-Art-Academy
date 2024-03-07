AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
FM = FataMorgana

class FM.Interface extends AM.Component
  # active: boolean whether the interface should react to user input
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
  #     overlays: array of overlays that appear above dialogs
  #       type: type of the overlay area
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

    @active = @data.child('active').value
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
    @_helperForFileInstances = {}
    @_loaders = {}
    @_loadersUpdatedDependency = new Tracker.Dependency

    # Create file loaders.
    @files = new AE.ReactiveArray =>
      editorViewsValues = @currentApplicationAreaData().findValuesOfChildrenOfType FM.EditorView

      files = (editorViewValue.files for editorViewValue in editorViewsValues)

      _.without _.flatten(files), undefined
    ,
      added: (file) =>
        loader = @options.loaders[file.documentClassId]
        @_loaders[file.id] = Tracker.nonreactive => new loader @, file.id
        @_loadersUpdatedDependency.changed()

      removed: (file) =>
        @_loaders[file.id].destroy()
        delete @_loaders[file.id]
        @_loadersUpdatedDependency.changed()

  onDestroyed: ->
    super arguments...

    @data.destroy()

  getComponentData: (componentClassOrId) ->
    componentId = _.snakeCase componentClassOrId.id?() or componentClassOrId
    @componentsData.child componentId

  getFileData: (fileId) ->
    @filesData.child fileId
  
  getActiveFileData: ->
    fileId = @activeFileId()
    return unless fileId?
  
    @getFileData fileId

  getComponentDataForFile: (componentClassOrId, fileId) ->
    componentId = _.snakeCase componentClassOrId.id?() or componentClassOrId

    @componentsForFilesData.child "#{fileId}.#{componentId}"

  getComponentDataForActiveFile: (componentClassOrId) ->
    fileId = @activeFileId()
    return unless fileId?

    @getComponentDataForFile componentClassOrId, fileId

  activateFile: (fileId) ->
    @activeFileId fileId
    
  getEditorViewForFile: (fileId) ->
    # Get all the editor views.
    editorViews = @allChildComponentsOfType FM.EditorView

    # Search for the editor view that has the file opened.
    for editorView in editorViews
      continue unless files = editorView.data().get('files')

      if _.find(files, (file) => file.id is fileId)
        return editorView

    null

  getEditorViewForActiveFile: ->
    @getEditorViewForFile @activeFileId()

  getEditorForActiveFile: ->
    @getEditorViewForActiveFile()?.getActiveEditor()
    
  getView: (viewClass) ->
    @allChildComponentsOfType(viewClass)[0]
    
  getHelper: (helperClassOrId) ->
    helperId = helperClassOrId.id?() or helperClassOrId

    # Create the helper singleton on first request.
    @_helperInstances[helperId] ?= Tracker.nonreactive =>
      helperClass = FM.Operator.getClassForId helperId
      @_helperInstances[helperId] = new helperClass @

    @_helperInstances[helperId]

  getHelperForFile: (helperClassOrId, fileId) ->
    helperId = helperClassOrId.id?() or helperClassOrId

    # Create the helper singleton on first request.
    @_helperForFileInstances[fileId] ?= {}

    unless @_helperForFileInstances[fileId][helperId]
      helperClass = FM.Operator.getClassForId helperId
      Tracker.nonreactive =>
        @_helperForFileInstances[fileId][helperId] = new helperClass @, fileId

    @_helperForFileInstances[fileId][helperId]

  getHelperForActiveFile: (helperClassOrId) ->
    fileId = @activeFileId()
    return unless fileId?

    @getHelperForFile helperClassOrId, fileId

  getLoaderForFile: (fileId) ->
    @_loadersUpdatedDependency.depend()
    @_loaders[fileId]

  getLoaderForActiveFile: ->
    @getLoaderForFile @activeFileId()

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
  
  overlays: ->
    overlaysData = @currentLayoutData().child 'overlays'
    return unless overlays = overlaysData.value()
    
    # Create child data objects to send as data.
    for overlay, index in overlays
      childData = overlaysData.child index
      childData._id = index
      childData

  # HACK: If we do this access directly in the template, the desktop build breaks since @
  # gets assigned to Interface in Tool classes for what must be an incredibly obscure reason.
  activeToolClasses: ->
    @activeTool()?.toolClasses()

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
