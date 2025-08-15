AM = Artificial.Mirage
AEc = Artificial.Echo
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Writer extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Writer'
  @register @id()

  @version: -> '0.1.0'

  @fullName: -> "Writer"
  @description: ->
    "
      Text document editor for Pixeltosh.
    "
    
  @slug: -> 'writer'

  @initialize()
  
  constructor: ->
    super arguments...
    
    @file = new ReactiveField null
  
  load: (file) ->
    super arguments...
    
    file ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pico8.Cartridges.Invasion}.DesignDocument"
      path: 'Document'
      data: =>
        documentComponentId: PAA.Pico8.Cartridges.Invasion.DesignDocument.id()
        projectId: AB.Router.getParameter('projectId') or AB.Router.getParameter('parameter4') or PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
    
    @file file
    
    @windowId = @os.addWindow @constructor.Interface.createInterfaceData file
  
  menuItems: -> @constructor.Interface.createMenuItems()
