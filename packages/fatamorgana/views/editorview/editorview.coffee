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

  editorData: ->
    editorData = @data()

    activeFileIndex = _.findIndex editorData.get('files'), (file) => file.active

    editorData.child "tabs.#{activeFileIndex}"

  events: ->
    super(arguments...).concat
      'click .tab': @onClickTab

  onClickTab: (event) ->
    clickedTab = @currentData()
    editorData = @data()

    # If we clicked an active tab we need to close all tabs.
    setToFalse = clickedTab.active

    for file, index in editorData.value().files
      value = if setToFalse then false else file is clickedTab

      editorData.child("files.#{index}").set 'active', value
