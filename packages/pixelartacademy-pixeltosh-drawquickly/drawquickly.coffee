AM = Artificial.Mirage
AEc = Artificial.Echo
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.DrawQuickly extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly'
  @register @id()

  @version: -> '0.1.0'

  @fullName: -> "Draw Quickly"
  @description: ->
    "
      A drawing game for Pixeltosh.
    "
    
  @slug: -> 'drawquickly'

  @initialize()
  
  constructor: ->
    super arguments...
  
  load: ->
    super arguments...
    
    @windowId = @os.addWindow @constructor.Interface.createInterfaceData()
  
  menuItems: -> @constructor.Interface.createMenuItems()
