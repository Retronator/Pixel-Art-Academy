AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

MarkupHelper = PAA.Practice.Helpers.Drawing.Markup
TextAlign = MarkupHelper.TextAlign
TextOriginPosition = MarkupHelper.TextOriginPosition

InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class PAA.Tutorials.Drawing.Markup
  @bottomRightClickHereMarkup: (selector, xOffset = 0) ->
    markup = []
    
    arrowBase = InterfaceMarking.arrowBase()
    textBase = InterfaceMarking.textBase()
    
    markup.push
      interface:
        selector: selector
        delay: 1
        bounds:
          x: -30 + xOffset
          y: -40
          width: 50
          height: 40
        markings: [
          line: _.extend {}, arrowBase,
            points: [
              x: xOffset, y: -25
            ,
              bezierControlPoints: [
                x: xOffset, y: -12
              ,
                x: 18 + xOffset, y: -20
              ]
              x: 18 + xOffset, y: -8
            ]
          text: _.extend {}, textBase,
            position:
              x: xOffset, y: -27, origin: TextOriginPosition.BottomCenter
            value: "click here"
        ]
    
    markup
