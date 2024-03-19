AC = Artificial.Control
FM = FataMorgana
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface
  @createMenuItems: ->
    [
      caption: ''
      items: []
    ,
      caption: 'File'
      items: [
        Pinball.Interface.Actions.Play.id()
        null
        PAA.Pixeltosh.OS.Interface.Actions.Quit.id()
      ]
    ,
      caption: 'View'
      items: [
        Pinball.Interface.Actions.OrthographicCamera.id()
        Pinball.Interface.Actions.PerspectiveCamera.id()
        null
        Pinball.Interface.Actions.ToggleDebugPhysics.id()
      ]
    ]
    
  @createShortcuts: ->
    "#{Pinball.Interface.Actions.Play.id()}": key: AC.Keys.p
    "#{Pinball.Interface.Actions.OrthographicCamera.id()}": key: AC.Keys[2]
    "#{Pinball.Interface.Actions.PerspectiveCamera.id()}": key: AC.Keys[3]
    "#{Pinball.Interface.Actions.ToggleDebugPhysics.id()}": commandOrControl: true, key: AC.Keys.d
    
  @createInterfaceData: ->
    type: PAA.Pixeltosh.Program.View.id()
    programId: PAA.Pixeltosh.Programs.Pinball.id()
    top: 14
    left: 0
    right: 0
    bottom: 0
    
  @createContentAreaData: (pinball) ->
    switch pinball.cameraManager().displayType()
      when Pinball.CameraManager.DisplayTypes.Orthographic
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
        
      when Pinball.CameraManager.DisplayTypes.Perspective
        contentComponentId: @Playfield.id()
