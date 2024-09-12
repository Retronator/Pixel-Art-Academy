AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies
  @pixelArtEvaluationClickHereCriterionMarkup: (criterionSelector) ->
    markupStyle = InterfaceMarking.defaultStyle()
    arrowBase = InterfaceMarking.arrowBase()
    textBase = InterfaceMarking.textBase()
    
    [
      interface:
        selector: ".pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation #{criterionSelector}"
        delay: 1
        bounds:
          x: -50
          y: -35
          width: 260
          height: 55
        markings: [
          rectangle:
            strokeStyle: markupStyle
            x: -2.5
            y: 2
            width: 199
            height: 13
          line: _.extend {}, arrowBase,
            points: [
              x: -32, y: -9
            ,
              x: -5, y: 8, bezierControlPoints: [
                x: -32, y: 3
              ,
                x: -15, y: 8
              ]
            ]
          text: _.extend {}, textBase,
            position:
              x: -32, y: -11, origin: Markup.TextOriginPosition.BottomCenter
            value: "click here"
        ]
    ]
