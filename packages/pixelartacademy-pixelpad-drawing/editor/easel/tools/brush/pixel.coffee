AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brush.Pixel extends LOI.Assets.SpriteEditor.Tools.Pencil
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brushes.Pixel'
  @displayName: -> "Pixel brush"

  extraToolClasses: -> 'brush'
  
  @initialize()
  
  onActivated: ->
    super arguments...
  
    @brushHelper.setRound true
  
    # Have our separate size for the pixel brush.
    @_previousToolBrushDiameter = @brushHelper.diameter()
    @brushHelper.setDiameter @_lastBrushDiameter or 1

  onDeactivated: ->
    super arguments...
    
    # Restore the previous brush size for other tools.
    @_lastBrushDiameter = @brushHelper.diameter()
    @brushHelper.setDiameter @_previousToolBrushDiameter
