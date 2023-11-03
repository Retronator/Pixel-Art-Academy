AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Easel.Tools.Brush.Square extends PAA.PixelPad.Apps.Drawing.Editor.Easel.Tools.Brush
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Easel.Tools.Brushes.Square'
  @displayName: -> "Square brush"
  
  @initialize()

  onActivated: ->
    super arguments...
    
    @brushHelper.setRound false
