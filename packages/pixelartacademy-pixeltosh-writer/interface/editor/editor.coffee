AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Writer = PAA.Pixeltosh.Programs.Writer

class Writer.Interface.Editor extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Writer.Interface.Editor'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @writer = @os.getProgram Writer
