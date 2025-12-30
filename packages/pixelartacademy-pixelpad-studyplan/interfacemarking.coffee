AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan
Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class StudyPlan.InterfaceMarking
  @defaultStyle: ->
    palette = LOI.palette()
    markupColor = palette.color Atari2600.hues.brown, 5
    
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
