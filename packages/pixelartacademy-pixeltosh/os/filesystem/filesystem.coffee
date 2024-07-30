AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.FileSystem extends LOI.Adventure.Location
  # files: object with user-defined properties of files.
  #   {fileId}:
  #     position: visual position of this file in Finder
  #       x, y
  #     path: a string specifying the custom full path (path + filename) of this file
  # folders: object with user-defined properties of folders.
  #   {folderPath}:
  #     window: dimensions of the folder window
  #       left, top, width, height
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.FileSystem'
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    @os = @options.os
    
    # Prepare for loading available programs based on gameplay.
    @currentFilesSituation = new AE.LiveComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @
      
      return unless options.timelineId
      
      new LOI.Adventure.Situation options
      
    @_folders = {}
    
  destroy: ->
    super arguments...
    
    @currentFilesSituation.stop()

  files: -> @currentFilesSituation().things()
  
  getFileForPath: (path) ->
    # Try to find a file with this path.
    return file for file in @files() when file.path() is path
    
    # Return a folder instead.
    @getFolderForPath path
  
  getFolderForPath: (path) ->
    @_folders[path] ?= new PAA.Pixeltosh.OS.FileSystem.File
      path: path
      type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Folder
  
    @_folders[path]
