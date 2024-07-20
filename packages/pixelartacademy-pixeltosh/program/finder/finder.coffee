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
    
    @selectedPath = new ReactiveField null
    
    @selectedFile = new ComputedField =>
      return unless selectedPath = @selectedPath()
      @os.fileSystem.getFileForPath selectedPath
  
  load: ->
    @os.addWindow @constructor.Desktop.createInterfaceData()
    
  menuItems: -> [
    caption: ''
    items: []
  ,
    caption: 'File'
    items: [
      PAA.Pixeltosh.OS.Interface.Actions.Open.id()
      null
      PAA.Pixeltosh.OS.Interface.Actions.Close.id()
      PAA.Pixeltosh.OS.Interface.Actions.CloseAll.id()
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
  
  selectPath: (path) ->
    @selectedPath path
    
  deselect: ->
    @selectedPath null
