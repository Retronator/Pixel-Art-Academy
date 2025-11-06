AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @drawQuickly = @os.getProgram DrawQuickly
