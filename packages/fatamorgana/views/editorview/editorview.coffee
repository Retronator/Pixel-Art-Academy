AM = Artificial.Mirage
FM = FataMorgana

class FM.EditorView extends FM.View
  # files: array of open files
  #   data: identifying data for the file
  #   active: true for the file that is currently displayed
  # editor:
  #   contentComponentId: the component to use for editing the active file
  @id: -> 'FataMorgana.EditorView'
  @register @id()

  onCreated: ->
    super arguments...

    @filesData = new ComputedField =>
      editorViewData = @data()
      files = editorViewData.get('files') or []
      file.data for file in files
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
      filesData = @filesData()
      contentComponentIdData = @contentComponentId()

      componentClass = AM.Component.getComponentForName contentComponentIdData
      componentClass.subscribeToDocumentsForEditorView @, filesData

  addFile: (fileData) ->
    editorViewData = @data()

    # Get all the current files and deactivate them.
    files = editorViewData.get('files') or []
    file.active = false for file in files

    # Add the new file and active it.
    files.push
      data: fileData
      active: true

    editorViewData.set 'files', files

  showTabs: ->
    # We show tabs when there are multiple files to switch between.
    @data().get('files')?.length > 1

  activeClass: ->
    tab = @currentData()
    'active' if tab.active

  tabData: ->
    file = @currentData()
    
    componentClass = AM.Component.getComponentForName @data().get('editor').contentComponentId
    componentClass.getDocumentForEditorView @, file.data

  events: ->
    super(arguments...).concat
      'click .tab': @onClickTab
      'click .editor': @onClickEditor

  onClickTab: (event) ->
    clickedFile = @currentData()
    editorViewData = @data()

    # If we clicked an active tab we need to close all tabs.
    setToFalse = clickedFile.active

    for file, index in editorViewData.value().files
      value = if setToFalse then false else file is clickedFile

      editorViewData.child("files.#{index}").set 'active', value

    @interface.activateFile clickedFile.data

  onClickEditor: (event) ->
    # Make sure the current tab is active globally.
    activeFile = @activeFileData().value()
    @interface.activateFile activeFile.data
