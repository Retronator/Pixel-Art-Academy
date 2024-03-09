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

  events: ->
    super(arguments...).concat
      'click .file-button': @onClickFileButton
  
  onClickFileButton: (event) ->
    file = @currentData()
    fileType = file.type()
    
    if fileType instanceof PAA.Pixeltosh.Program
      program = @os.getProgram fileType
      @os.loadProgram program

    else if fileType in [PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk, PAA.Pixeltosh.OS.FileSystem.FileTypes.Folder]
      @os.addWindow PAA.Pixeltosh.Programs.Finder.Folder.createInterfaceData file
