AC = Artificial.Control
FM = FataMorgana
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface
  @createMenuItems: ->
    [
      caption: ''
      items: [
        DrawQuickly.Interface.Actions.About.id()
      ]
    ,
      caption: 'File'
      items: [
        PAA.Pixeltosh.OS.Interface.Actions.Quit.id()
      ]
    ,
      caption: 'Game'
      items: [
        DrawQuickly.Interface.Actions.BackToSplash.id()
        DrawQuickly.Interface.Actions.Restart.id()
      ]
    ]
    
  @createInterfaceData: (documentFile) ->
    type: PAA.Pixeltosh.Program.View.id()
    programId: PAA.Pixeltosh.Programs.DrawQuickly.id()
    top: 14
    left: 0
    right: 0
    bottom: 0
    contentArea:
      type: DrawQuickly.Interface.Game.id()
