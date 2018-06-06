AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Theme.School.ColorFill extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.ColorFill'
  
  onCreated: ->
    super
    
    @theme = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Theme.School

  colorStyle: ->
    # Get the color from the palette.
    colorData = @theme.palette().currentColor()
    return unless colorData

    color = THREE.Color.fromObject colorData
    active = @theme.activeTool() instanceof LOI.Assets.SpriteEditor.Tools.ColorFill

    backgroundColor: "##{color.getHexString()}"
    opacity: if active then 0.9 else 0.7
