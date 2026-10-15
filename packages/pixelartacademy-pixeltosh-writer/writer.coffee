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
  
  load: (file) ->
    super arguments...
    
    @windowId = @os.addWindow @constructor.Interface.createInterfaceData file
  
  menuItems: -> @constructor.Interface.createMenuItems()
