AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.ColorFill extends FM.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.ColorFill'
  @register @id()
  
  @template: -> @constructor.id()
  
  onCreated: ->
    super arguments...
  
    @paletteData = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()?.getRestrictedPalette()
  
    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
  
    @currentColor = new ComputedField =>
      return unless paletteColor = @paintHelper.paletteColor()
      @paletteData()?.ramps[paletteColor.ramp]?.shades[paletteColor.shade]
      
  colorStyle: ->
    # Get the color from the palette.
    colorData = @currentColor()
    return unless colorData

    color = THREE.Color.fromObject colorData
    active = @interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.ColorFill.id()

    backgroundColor: "##{color.getHexString()}"
    opacity: if active then 1 else 0.8
