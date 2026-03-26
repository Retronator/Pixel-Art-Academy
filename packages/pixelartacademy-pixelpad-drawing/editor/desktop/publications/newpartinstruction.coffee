AM = Artificial.Mirage
AMu = Artificial.Mummification
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Publications.NewPartInstruction extends PAA.PixelPad.Systems.Instructions.Instruction
  @id: -> "PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Publications.NewPartInstruction"
  
  @activeConditions: ->
    # Show when there is an unread publication part among the displayed publications.
    return unless editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
    return unless editor.drawingActive()
    return unless publicationsView = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.Publications
    return if publicationsView.active()
    
    currentPartsSituation = new LOI.Adventure.Situation
      location: PAA.Publication.Part.Location
    
    unlockedPartIds = currentPartsSituation.things()
    
    for publicationInfo in publicationsView.publications()
      return true if publicationInfo.publication.hasUnreadUnlockedContents unlockedPartIds
    
    false
  
  @activeDisplayState: ->
    # We only have markup without a message.
    PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
  
  @initialize()
  
  markup: ->
    markup = []
    
    arrowBase = InterfaceMarking.arrowBase()
    textBase = InterfaceMarking.textBase()
    
    markup.push
      interface:
        selector: '.pixelartacademy-publication-component .publication'
        delay: 1
        bounds:
          x: 40
          y: -40
          width: 100
          height: 40
        markings: [
          line: _.extend {}, arrowBase,
            points: [
              x: 90, y: -30
            ,
              x: 100, y: -7, bezierControlPoints: [
                x: 90, y: -25
              ,
                x: 90, y: -20
              ]
            ]
          text: _.extend {}, textBase,
            position:
              x: 90, y: -32, origin: Markup.TextOriginPosition.BottomCenter
            value: "new article unlocked"
        ]
    
    markup
