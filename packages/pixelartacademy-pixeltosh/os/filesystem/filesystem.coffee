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
      
  destroy: ->
    super arguments...
    
    @currentFilesSituation.stop()

  files: -> @currentFilesSituation().things()
