AC = Artificial.Control
FM = FataMorgana
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface
  @Layouts:
    MenuIntro: 'MenuIntro'
    Menu: 'Menu'
    Lesson: 'Lesson'
    Play: 'Play'
    
  @createMenuItems: ->
    [
      caption: ''
      items: [
        Chess.Interface.Actions.About.id()
      ]
    ,
      caption: 'File'
      items: [
        Chess.Interface.Actions.BackToMenu.id()
        null
        PAA.Pixeltosh.OS.Interface.Actions.Quit.id()
      ]
    ,
      caption: 'View'
      items: [
        Chess.Interface.Actions.BoardDisplay2D.id()
        Chess.Interface.Actions.BoardDisplay3D.id()
      ]
    ]
    
  @createShortcuts: -> {}
    
  @createInterfaceData: ->
    type: PAA.Pixeltosh.Program.View.id()
    programId: PAA.Pixeltosh.Programs.Chess.id()
    top: 14
    left: 0
    right: 0
    bottom: 0

  @createLayoutsData: ->
    "#{@Layouts.MenuIntro}":
      type: FM.SplitView.id()
      fixed: true
      dockSide: FM.SplitView.DockSide.Left
      mainArea:
        contentComponentId: @Chessboard.id()
        width: 200
      remainingArea:
        type: FM.SplitView.id()
        fixed: true
        dockSide: FM.SplitView.DockSide.Top
        mainArea:
          contentComponentId: @Intro.id()
          height: 152
        remainingArea:
          contentComponentId: @PlayerStatus.id()
