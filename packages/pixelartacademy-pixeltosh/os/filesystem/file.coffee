LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.FileSystem.File
  constructor: (@options) ->
  
  id: -> @options.id
  
  path: ->
    files = PAA.Pixeltosh.OS.FileSystem.state('files') or {}
    files[@id()]?.path or @options.path
    
  pathParts: ->
    fullPath = @path()
    pathParts = fullPath.split '/'
    
    # Last part is always the filename, the rest is the path.
    filename = _.last pathParts
    folders = _.initial pathParts
    
    path = folders.join '/'
    
    {path, folders, filename}
    
  name: -> @pathParts().filename
  
  type: -> @options.type
  
  iconUrl: -> @type().iconUrl()
  
  data: -> @options.data?()
