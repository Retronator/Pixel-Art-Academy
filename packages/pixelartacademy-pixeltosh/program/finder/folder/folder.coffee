AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Folder extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Folder'
  @register @id()
  
  @createInterfaceData: (folder) ->
    folderPath = folder.path()
    folders = PAA.Pixeltosh.OS.FileSystem.state('folders') or {}
    
    window = _.defaults folders[folderPath]?.window or {},
      left: 50
      top: 50
      width: 150
      height: 100
    
    _.extend window,
      type: PAA.Pixeltosh.Program.View.id()
      programId: PAA.Pixeltosh.Programs.Finder.id()
      contentArea:
        type: PAA.Pixeltosh.OS.Interface.Window.id()
        title:
          text: folder.name()
        contentArea:
          type: @id()
          path: folderPath

  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    
    @window = @ancestorComponentOfType PAA.Pixeltosh.OS.Interface.Window
    @window.moved.addHandler @, @onWindowMoved
    
    @folderPath = =>
      folderData = @data()
      folderData.get 'path'
    
  onDestroyed: ->
    super arguments...
    
    @window.moved.removeHandler @, @onWindowMoved
  
  files: ->
    folderPath = @folderPath()
    folderPathFolders = folderPath.split '/'
    
    # Show all files at the given path.
    allFiles = @os.fileSystem.files()
    
    files = []
    folderNames = []
    
    for file in allFiles
      pathParts = file.pathParts()
      continue unless _.startsWith pathParts.path, folderPath
      
      if pathParts.path is folderPath
        # This is a file in this folder
        files.push file
        
      else
        # This is a file deeper in this folder. Extract the subfolder name.
        subfolderName = pathParts.folders[folderPathFolders.length]
        folderNames.push subfolderName unless subfolderName in folderNames
      
    folders = for folderName in folderNames
      new PAA.Pixeltosh.OS.FileSystem.File
        path: "#{folderPath}/#{folderName}"
        type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Folder
    
    [files..., folders...]

  onWindowMoved: (newPosition) ->
    # Store window size.
    folderPath = @folderPath()
    folders = PAA.Pixeltosh.OS.FileSystem.state('folders') or {}
    folders[folderPath] ?= {}
    
    _.merge folders[folderPath],
      window: newPosition
    
    PAA.Pixeltosh.OS.FileSystem.state 'folders', folders
