AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder'
  @register @id()

  @version: -> '0.1.0'

  @fullName: -> "Finder"
  @description: ->
    "
      The file system manager of Pixeltosh.
    "
    
  @slug: -> 'finder'

  @initialize()
  
  constructor: ->
    super arguments...
    
    @openFolders = {}
    
    @selectedFolderPath = new ReactiveField null
    @selectedFileId = new ReactiveField null
    
    # Note: Selected file can also be a folder, which means the icon in finder that represents the folder.
    @selectedFile = new ComputedField =>
      if selectedFileId = @selectedFileId()
        return @os.fileSystem.getFileForId selectedFileId
        
      else if selectedFolderPath = @selectedFolderPath()
        return @os.fileSystem.getFolderForPath selectedFolderPath
        
      null
  
  load: ->
    @os.addWindow @constructor.Desktop.createInterfaceData()
    
  menuItems: -> [
    caption: ''
    items: [
      PAA.Pixeltosh.Programs.Finder.Actions.About.id()
    ]
  ,
    caption: 'File'
    items: [
      PAA.Pixeltosh.Programs.Finder.Actions.Open.id()
      PAA.Pixeltosh.Programs.Finder.Actions.Rename.id()
      PAA.Pixeltosh.Programs.Finder.Actions.Delete.id()
    ]
  ,
    caption: 'Window'
    items: [
      PAA.Pixeltosh.Programs.Finder.Actions.Close.id()
      PAA.Pixeltosh.Programs.Finder.Actions.CloseAll.id()
    ]
  ]
  
  openFolder: (folderFile) ->
    # See if this folder is already open and we can simply activate it.
    path = folderFile.path()
    
    if openFolder = @openFolders[path]
      @os.activateWindow openFolder.windowId
      return
    
    parentPath = folderFile.parentPath()
  
    if @openFolders[parentPath]
      parentFolderView = @os.interface.getWindow @openFolders[parentPath].windowId
    
    # We need to open the folder in a new window.
    @os.addWindow PAA.Pixeltosh.Programs.Finder.Folder.createInterfaceData folderFile, parentFolderView
  
  registerFolderWindow: (path, windowId) ->
    @openFolders[path] = {windowId}
  
  deregisterFolderWindow: (path) ->
    delete @openFolders[path]
  
  selectFolderPath: (path) ->
    @selectedFolderPath path
    @selectedFileId null

  selectFile: (file) ->
    @selectedFolderPath if file.type() is PAA.Pixeltosh.OS.FileSystem.FileTypes.Folder then file.path() else null
    @selectedFileId file.id()
    
  deselect: ->
    @selectedFolderPath null
    @selectedFileId null
