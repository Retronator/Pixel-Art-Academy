AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.PixeltoshFiles extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.PixeltoshFiles'

  @location: -> PAA.Pixeltosh.OS.FileSystem

  @initialize()
  
  things: ->
    return [] unless LM.Design.invasionEnabled()

    unless @_invasionDisk
      @_invasionDisk = new PAA.Pixeltosh.OS.FileSystem.File
        id: "#{PAA.Pico8.Cartridges.Invasion.id()}.Disk"
        path: 'Invasion'
        type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
      
      @_invasionDisk.options.disk = @_invasionDisk
      
    files = [
      @_invasionDisk
    ]
    
    @_invasionDesignDocuments ?= {}
    
    for project in PAA.Pico8.Cartridges.Invasion.Project.getProjects()
      @_invasionDesignDocuments[project._id] ?= new PAA.Pico8.Cartridges.Invasion.DesignDocument.File project._id, @_invasionDisk
      files.push @_invasionDesignDocuments[project._id]

    if PAA.Pico8.Cartridges.Invasion.Project.editable()
      @_createInvasionProject ?= new PAA.Pixeltosh.Programs.NewProject.File PAA.Pico8.Cartridges.Invasion.Project, @_invasionDisk
      files.push @_createInvasionProject

    files
