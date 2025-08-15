LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.PixeltoshFiles extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.PixeltoshFiles'

  @location: -> PAA.Pixeltosh.OS.FileSystem

  @initialize()
  
  things: ->
    unless @_invasionDisk
      @_invasionDisk = new PAA.Pixeltosh.OS.FileSystem.File
        id: "#{PAA.Pico8.Cartridges.Invasion.id()}.Disk"
        path: 'Invasion'
        type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
      
      @_invasionDisk.options.disk = @_invasionDisk
      
    @_invasionDesignDocument ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pico8.Cartridges.Invasion}.DesignDocument"
      path: 'Invasion/Invasion Design Document'
      type: PAA.Pixeltosh.Programs.Writer.TextDocument
      disk: @_invasionDisk
      data: =>
        documentComponentId: PAA.Pico8.Cartridges.Invasion.DesignDocument.id()
        projectId: PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
    
    invasionEnabled = LM.Design.invasionEnabled()
    
    [
      @_invasionDisk if invasionEnabled
      @_invasionDesignDocument if invasionEnabled
    ]
