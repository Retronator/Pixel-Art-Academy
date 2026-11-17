AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Planning.StudyPlan.InterfaceMarking
  @defaultStyle: ->
    palette = LOI.palette()
    markupColor = palette.color Atari2600.hues.aqua, 5
    
    "##{markupColor.getHexString()}"
  
  @textBase: ->
    size: 5
    lineHeight: 7
    font: 'Small Print Retronator'
    style: @defaultStyle()
    align: Markup.TextAlign.Center
  
  @arrowBase: ->
    arrow:
      end: true
      width: 6
      length: 3
    style: @defaultStyle()
