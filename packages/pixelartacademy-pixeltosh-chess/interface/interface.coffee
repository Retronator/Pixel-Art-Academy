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
        null
        Chess.Interface.Actions.DisplayBoardCoordinates.id()
        null
        Chess.Interface.Actions.FlipBoard.id()
      ]
    ]
    
  @createShortcuts: ->
    "#{Chess.Interface.Actions.FlipBoard.id()}": key: AC.Keys.f
    
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
        width: 199
      remainingArea:
        type: FM.SplitView.id()
        fixed: true
        dockSide: FM.SplitView.DockSide.Top
        mainArea:
          contentComponentId: @Intro.id()
          height: 152
        remainingArea:
          contentComponentId: @PlayerStatus.id()

    "#{@Layouts.Menu}":
      type: FM.SplitView.id()
      fixed: true
      dockSide: FM.SplitView.DockSide.Left
      mainArea:
        contentComponentId: @Chessboard.id()
        width: 199
      remainingArea:
        type: FM.SplitView.id()
        fixed: true
        dockSide: FM.SplitView.DockSide.Bottom
        styleClass: 'pixelartacademy-pixeltosh-chess-interface-sidebar'
        mainArea:
          contentComponentId: @PlayerStatus.id()
          height: 45
        remainingArea:
          type: FM.TabbedView.id()
          tabs: [
            name: 'Lessons'
            contentComponentId: @Intro.id()
          ,
            name: 'Play'
            contentComponentId: @PlayStart.id()
          ]
          allowClosing: false

    "#{@Layouts.Play}":
      type: FM.SplitView.id()
      fixed: true
      dockSide: FM.SplitView.DockSide.Left
      mainArea:
        contentComponentId: @Chessboard.id()
        width: 199
      remainingArea:
        type: FM.TabbedView.id()
        styleClass: 'pixelartacademy-pixeltosh-chess-interface-sidebar'
        tabs: [
          name: 'Play'
          contentComponentId: @Play.id()
          active: true
        ,
          name: 'Overlays'
        ]
        allowClosing: false
