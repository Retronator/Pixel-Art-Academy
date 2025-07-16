AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Folder extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Folder'
  @register @id()
  
  @createInterfaceData: (folderFile, parentFolderView) ->
    folderPath = folderFile.path()
    folders = PAA.Pixeltosh.OS.FileSystem.state('folders') or {}
    
    unless window = folders[folderPath]?.window
      if parentFolderView
        parentData = parentFolderView.data()
        window =
          left: parentData.get('left') + 10
          top: parentData.get('top') + 10
      
      else
        window = {}
      
    _.defaults window,
      left: 50
      top: 50
      width: 200
      height: 100
      scrollLeft: 0
      scrollTop: 0
    
    _.extend window,
      type: PAA.Pixeltosh.Program.View.id()
      programId: PAA.Pixeltosh.Programs.Finder.id()
      contentArea:
        type: PAA.Pixeltosh.OS.Interface.Window.id()
        title:
          text: folderFile.name()
        scrollbar:
          vertical:
            enabled: true
          horizontal:
            enabled: true
        contentArea:
          type: @id()
          path: folderPath

  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @finder = @os.getProgram PAA.Pixeltosh.Programs.Finder
    
    @interfaceWindow = @ancestorComponentOfType PAA.Pixeltosh.OS.Interface.Window
    @interfaceWindow.changed.addHandler @, @onWindowChanged
    
    @folderPath = =>
      folderData = @data()
      folderData.get 'path'
    
    @programView = @ancestorComponentOfType PAA.Pixeltosh.Program.View
    @windowId = @programView.windowId()
    
    @autorun (computation) =>
      if @_currentFolderPath
        @finder.deregisterFolderWindow @_currentFolderPath
      
      if @_currentFolderPath = @folderPath()
        @finder.registerFolderWindow @_currentFolderPath, @windowId
    
  onDestroyed: ->
    super arguments...
    
    @finder.deregisterFolderWindow @_currentFolderPath if @_currentFolderPath
    
    @interfaceWindow.changed.removeHandler @, @onWindowChanged
  
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
      @os.fileSystem.getFolderForPath "#{folderPath}/#{folderName}"
    
    [files..., folders...]

  onWindowChanged: (newProperties) ->
    # Store window properties.
    folderPath = @folderPath()
    folders = PAA.Pixeltosh.OS.FileSystem.state('folders') or {}
    folders[folderPath] ?= {}
    
    _.merge folders[folderPath],
      window: newProperties
    
    PAA.Pixeltosh.OS.FileSystem.state 'folders', folders

  events: ->
    super(arguments...).concat
      'pointerdown .pixelartacademy-pixeltosh-programs-finder-folder': @onPointerDownFolder
  
  onPointerDownFolder: (event) ->
    return if $(event.target).closest('.file-button').length
    
    @finder.selectPath @folderPath()
