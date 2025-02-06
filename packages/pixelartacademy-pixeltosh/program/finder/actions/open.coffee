AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Actions.Open extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Actions.Open'
  @displayName: -> "Open"

  @initialize()
  
  constructor: ->
    super arguments...
    
    @finder = @os.getProgram PAA.Pixeltosh.Programs.Finder
  
  enabled: ->
    # We can perform open when a file is selected.
    @finder.selectedFile()
  
  execute: ->
    file = @finder.selectedFile()
    fileType = file.type()
    
    if fileType.prototype instanceof PAA.Pixeltosh.Program
      program = @os.getProgram fileType
      @os.loadProgram program
    
    else if fileType in [PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk, PAA.Pixeltosh.OS.FileSystem.FileTypes.Folder]
      @finder.openFolder file
      
    else if programClass = fileType.program?()
      program = @os.getProgram programClass
      @os.loadProgram program, file
