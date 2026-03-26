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
    'selected' if @finder.selectedPath() is file.path()

  events: ->
    super(arguments...).concat
      'pointerdown .file-button': @onPointerDownFileButton
      'dblclick .file-button': @onDoubleClickFileButton
 
  onPointerDownFileButton: (event) ->
    file = @currentData()
    @finder.selectPath file.path()
  
  onDoubleClickFileButton: (event) ->
    @os.interface.getOperator(PAA.Pixeltosh.Programs.Finder.Actions.Open).execute()
