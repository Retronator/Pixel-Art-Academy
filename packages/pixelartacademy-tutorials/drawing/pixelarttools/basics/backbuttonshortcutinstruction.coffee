AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Basics = PAA.Tutorials.Drawing.PixelArtTools.Basics
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class Basics.BackButtonShortcutInstruction extends PAA.PixelPad.Systems.Instructions.Instruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.BackButtonShortcutInstruction"
  
  @priority: -> 10
  
  @activeDisplayState: ->
    # We only have markup without a message.
    InstructionsSystem.DisplayState.Hidden
  
  @initialize()

  activeConditions: ->
    # Show this until the player used the shortcut for the back button.
    return if PAA.Tutorials.Drawing.PixelArtTools.Basics.state 'backButtonShortcutUsed'
    
    # Show this only when we're on a completed color fill tutorial (1 or 2).
    return unless editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
    return unless activeAsset = editor.activeAsset()
    return unless activeAsset.constructor in [Basics.ColorFill, Basics.ColorFill2]
    return unless editor.drawingActive()
    activeAsset.completed?()

  markup: ->
    markupStyle = InterfaceMarking.defaultStyle()
    textBase = InterfaceMarking.textBase()
    
    [
      interface:
        selector: ".landsofillusions-components-back-button"
        bounds:
          x: -10
          y: -10
          width: 200
          height: 40
        markings: [
          line: _.extend {},
            style: markupStyle
            points: [
              x: 16, y: -3
            ,
              x: 0, y: 21, bezierControlPoints: [
                x: 3, y: -7
              ,
                x: -11, y: 10
              ]
            ,
              x: 26, y: 5, bezierControlPoints: [
                x: 10, y: 29
              ,
                x: 31, y: 18
              ]
            ,
              x: 14, y: 1, bezierControlPoints: [
                x: 24, y: 1
              ,
                x: 18, y: -3
              ]
            ]
          text: _.extend {}, textBase,
            position:
              x: 53, y: 10, origin: Markup.TextOriginPosition.MiddleLeft
            value: "You can press escape\ninstead of using the back arrow."
            align: Markup.TextAlign.Left
        ]
    ]
