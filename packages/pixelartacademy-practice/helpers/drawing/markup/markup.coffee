LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Practice.Helpers.Drawing.Markup
  @TextOriginPosition =
    TopLeft: 'TopLeft'
    TopCenter: 'TopCenter'
    TopRight: 'TopRight'
    MiddleLeft: 'MiddleLeft'
    MiddleCenter: 'MiddleCenter'
    MiddleRight: 'MiddleRight'
    BottomLeft: 'BottomLeft'
    BottomCenter: 'BottomCenter'
    BottomRight: 'BottomRight'
  
  @TextAlign =
    Left: 'Left'
    Center: 'Center'
    Right: 'Right'

  @defaultStyle: ->
    palette = LOI.palette()
    markupColor = palette.color Atari2600.hues.azure, 4
    
    "##{markupColor.getHexString()}"
  
  @betterStyle: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.green, 4
    
    "##{lineColor.getHexString()}"
  
  @mediocreStyle: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.yellow, 4
    
    "##{lineColor.getHexString()}"
  
  @worseStyle: ->
    palette = LOI.palette()
    lineColor = palette.color Atari2600.hues.peach, 5
    
    "##{lineColor.getHexString()}"
    
  @errorStyle: ->
    palette = LOI.palette()
    errorColor = palette.color Atari2600.hues.red, 3
    
    "##{errorColor.getHexString()}"
    
  @textBase: ->
    size: 6
    lineHeight: 7
    font: 'Small Print Retronator'
    style: @defaultStyle()
    align: @TextAlign.Center
  
  @percentage: (value) ->
    return "N/A" unless value?
    
    "#{Math.floor value * 100}%"
