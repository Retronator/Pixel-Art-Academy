AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Easel.ColorFill extends FM.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Easel.ColorFill'
  @register @id()
  
  onCreated: ->
    super arguments...
  
    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
  
    @currentColor = new ComputedField => @paintHelper.getColor()
    
  colorStyle: ->
    # Get the color from the palette.
    color = @currentColor()
    return unless color

    active = @interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.ColorFill.id()

    backgroundColor: "##{color.getHexString()}"
    opacity: if active then 1 else 0.8
