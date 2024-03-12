FM = FataMorgana
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Pinball.Interface
  @createInterfaceData: ->
    type: PAA.Pixeltosh.Program.View.id()
    programId: PAA.Pixeltosh.Programs.Pinball.id()
    top: 14
    left: 0
    right: 0
    bottom: 0
    contentArea:
      type: FM.SplitView.id()
      fixed: true
      dockSide: FM.SplitView.DockSide.Left
      mainArea:
        contentComponentId: @Playfield.id()
        width: 180
      remainingArea:
        type: FM.SplitView.id()
        fixed: true
        dockSide: FM.SplitView.DockSide.Top
        mainArea:
          contentComponentId: @Backbox.id()
          height: 140
        remainingArea:
          contentComponentId: @Instructions.id()
