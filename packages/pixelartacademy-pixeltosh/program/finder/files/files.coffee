AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Files extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Files'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @finder = @os.getProgram PAA.Pixeltosh.Programs.Finder
  
  selectedClass: ->
    file = @currentData()
    
    if selectedFileId = @finder.selectedFileId()
      'selected' if selectedFileId is file.id()
    
    else if selectedFolderPath = @finder.selectedFolderPath()
      'selected' if selectedFolderPath is file.path()

  events: ->
    super(arguments...).concat
      'pointerdown .file-button': @onPointerDownFileButton
      'dblclick .file-button': @onDoubleClickFileButton
 
  onPointerDownFileButton: (event) ->
    file = @currentData()
    @finder.selectFile file
  
  onDoubleClickFileButton: (event) ->
    @os.interface.getOperator(PAA.Pixeltosh.Programs.Finder.Actions.Open).execute()
