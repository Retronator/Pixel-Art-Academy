FM = FataMorgana
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Pinball extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball'
  @register @id()
  
  @version: -> '0.1.0'
  
  @fullName: -> "Pinball Creation Kit"
  @description: ->
    "
      A do-it-yourself Pinball game.
    "
  
  @programSlug: -> 'pinball'
  
  @initialize()
  
  load: ->
    @os.addWindow
      contentComponentId: PAA.Pixeltosh.Programs.Pinball.Playfield.id()
      left: 0
      top: 14
      right: 0
      bottom: 0
      
  menuItems: -> [
    caption: ''
    items: []
  ,
    caption: 'File'
    items: []
  ]
