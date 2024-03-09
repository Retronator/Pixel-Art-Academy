AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Desktop extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Desktop'
  @register @id()
  
  @createInterfaceData: ->
    type: PAA.Pixeltosh.Program.View.id()
    programId: PAA.Pixeltosh.Programs.Finder.id()
    activateBringsWindowToTop: false
    top: 14
    left: 0
    right: 0
    bottom: 0
    contentArea:
      contentComponentId: @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent

  files: ->
    # Show all files at the root folder.
    files = @os.fileSystem.files()
    
    rootFiles = []
    diskNames = []
    rootFolderNames = []
    
    for file in files
      pathParts = file.pathParts()
      
      unless pathParts.path
        rootFiles.push file
        
        if file.type() is PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
          diskNames.push pathParts.filename
      
      if rootFolderName = _.first pathParts.folders
        rootFolderNames.push rootFolderName unless rootFolderName in rootFolderNames or rootFolderName in diskNames
      
    rootFolders = for rootFolderName in rootFolderNames
      new PAA.Pixeltosh.OS.FileSystem.File
        path: rootFolderName
        type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Folder
    
    [rootFiles..., rootFolders...]
