AC = Artificial.Control
FM = FataMorgana
PAA = PixelArtAcademy
Writer = PAA.Pixeltosh.Programs.Writer

class Writer.Interface
  @createMenuItems: ->
    [
      caption: ''
      items: [
        Writer.Interface.Actions.About.id()
      ]
    ,
      caption: 'File'
      items: [
      ]
    ]
    
  @createInterfaceData: (documentFile) ->
    type: PAA.Pixeltosh.Program.View.id()
    programId: PAA.Pixeltosh.Programs.Writer.id()
    top: 16
    left: 2
    width: 320 - 5
    height: 200 - 5
    contentArea:
      type: PAA.Pixeltosh.OS.Interface.Window.id()
      title:
        text: documentFile.name()
      scrollbar:
        vertical:
          enabled: true
      contentArea:
        type: Writer.Interface.Editor.id()
