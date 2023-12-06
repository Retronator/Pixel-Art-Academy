LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextAlign = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextAlign
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @markupStyle: ->
    palette = LOI.palette()
    markupColor = palette.color Atari2600.hues.azure, 4
    
    "##{markupColor.getHexString()}"
    
  @markupTextBase: ->
    size: 6
    lineHeight: 7
    font: 'Small Print Retronator'
    style: @markupStyle()
    align: TextAlign.Center
    
  @markupIntendedLineBase: ->
    palette = LOI.palette()
    intendedLineColor = palette.color Atari2600.hues.azure, 5

    style: "##{intendedLineColor.getHexString()}"

  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
  
  minClipboardScale: -> 2
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
    ]
