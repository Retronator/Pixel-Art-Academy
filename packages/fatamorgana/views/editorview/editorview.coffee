AM = Artificial.Mirage
FM = FataMorgana

class FM.EditorView extends FM.View
  # files: array of open files
  #   id: identifier for the file
  #   active: true for the file that is currently displayed
  # editor:
  #   contentComponentId: the component to use for editing the active file
  @id: -> 'FataMorgana.EditorView'
  @register @id()

  onCreated: ->
    super arguments...

    @fileIds = new ComputedField =>
      editorViewData = @data()
      files = editorViewData.get('files') or []
      file.id for file in files
    ,
      EJSON.equals

    @activeFileIndex = new ComputedField =>
      editorViewData = @data()
      _.findIndex editorViewData.get('files'), (file) => file.active

    @activeFileData = new ComputedField =>
      editorViewData = @data()
      editorViewData.child "files.#{@activeFileIndex()}"

    @contentComponentId = new ComputedField =>
      editorViewData = @data()
      editorViewData.child('editor').get 'contentComponentId'

    @autorun (computation) =>
      fileIds = @fileIds()
      contentComponentIdData = @contentComponentId()

      componentClass = AM.Component.getComponentForName contentComponentIdData
      componentClass.subscribeToDocumentsForEditorView @, fileIds

  addFile: (fileId) ->
    editorViewData = @data()

    # Get all the current files and deactivate them.
    files = editorViewData.get('files') or []
    file.active = false for file in files

    # Add the new file and active it.
    files.push
      id: fileId
      active: true

    editorViewData.set 'files', files

    @interface.activateFile fileId
    
  getActiveEditor: ->
    componentClass = AM.Component.getComponentForName @data().get('editor').contentComponentId
    @allChildComponentsOfType(componentClass)[0]

  showTabs: ->
    # We show tabs when there are multiple files to switch between.
    @data().get('files')?.length > 1

  activeClass: ->
    tab = @currentData()
    'active' if tab.active

  tabData: ->
    file = @currentData()
    
    componentClass = AM.Component.getComponentForName @data().get('editor').contentComponentId
    componentClass.getDocumentForEditorView @, file.id

  events: ->
    super(arguments...).concat
      'click .tab': @onClickTab
      'click .editor': @onClickEditor

  onClickTab: (event) ->
    clickedFile = @currentData()
    editorViewData = @data()

    for file, index in editorViewData.value().files
      editorViewData.child("files.#{index}").set 'active', file is clickedFile

    @interface.activateFile clickedFile.id

  onClickEditor: (event) ->
    # Make sure the current tab is active globally.
    activeFile = @activeFileData().value()
    @interface.activateFile activeFile.id
