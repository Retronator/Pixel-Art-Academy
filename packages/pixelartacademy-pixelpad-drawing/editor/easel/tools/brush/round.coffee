AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Easel.Tools.Brush.Round extends PAA.PixelPad.Apps.Drawing.Editor.Easel.Tools.Brush
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Easel.Tools.Brushes.Round'
  @displayName: -> "Round brush"
  
  @initialize()
  
  onActivated: ->
    super arguments...
    
    @brushHelper.setRound true
