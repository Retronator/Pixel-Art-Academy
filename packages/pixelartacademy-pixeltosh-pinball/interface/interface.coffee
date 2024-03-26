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
        Pinball.Interface.Actions.Edit.id()
        Pinball.Interface.Actions.Test.id()
        Pinball.Interface.Actions.Play.id()
        null
        Pinball.Interface.Actions.Reset.id()
        null
        PAA.Pixeltosh.OS.Interface.Actions.Quit.id()
      ]
    ,
      caption: 'Edit'
      items: [
        Pinball.Interface.Actions.Delete.id()
        Pinball.Interface.Actions.Flip.id()
        Pinball.Interface.Actions.RotateClockwise.id()
        Pinball.Interface.Actions.RotateCounterClockwise.id()
      ]
    ,
      caption: 'View'
      items: [
        Pinball.Interface.Actions.OrthographicCamera.id()
        Pinball.Interface.Actions.PerspectiveCamera.id()
        null
        Pinball.Interface.Actions.ToggleDebugPhysics.id()
        Pinball.Interface.Actions.ToggleSlowMotion.id()
      ]
    ]
    
  @createShortcuts: ->
    "#{Pinball.Interface.Actions.Edit.id()}": key: AC.Keys.e
    "#{Pinball.Interface.Actions.Test.id()}": key: AC.Keys.t
    "#{Pinball.Interface.Actions.Play.id()}": key: AC.Keys.p
    "#{Pinball.Interface.Actions.Reset.id()}": key: AC.Keys.r
    "#{Pinball.Interface.Actions.Delete.id()}": [{key: AC.Keys.delete}, {key: AC.Keys.backspace}]
    "#{Pinball.Interface.Actions.Flip.id()}": commandOrControl: true, key: AC.Keys.f
    "#{Pinball.Interface.Actions.RotateClockwise.id()}": commandOrControl: true, key: AC.Keys.r
    "#{Pinball.Interface.Actions.RotateCounterClockwise.id()}": commandOrControl: true, shift: true, key: AC.Keys.r
    "#{Pinball.Interface.Actions.OrthographicCamera.id()}": key: AC.Keys[2]
    "#{Pinball.Interface.Actions.PerspectiveCamera.id()}": key: AC.Keys[3]
    "#{Pinball.Interface.Actions.ToggleDebugPhysics.id()}": key: AC.Keys.d
    "#{Pinball.Interface.Actions.ToggleSlowMotion.id()}": key: AC.Keys.s
    
  @createInterfaceData: ->
    type: PAA.Pixeltosh.Program.View.id()
    programId: PAA.Pixeltosh.Programs.Pinball.id()
    top: 14
    left: 0
    right: 0
    bottom: 0
    
  @createContentAreaData: (pinball) ->
    switch pinball.cameraManager()?.displayType()
      when Pinball.CameraManager.DisplayTypes.Orthographic
        switch pinball.gameManager().mode()
          when Pinball.GameManager.Modes.Edit, Pinball.GameManager.Modes.Test
            type: FM.SplitView.id()
            fixed: true
            dockSide: FM.SplitView.DockSide.Left
            mainArea:
              contentComponentId: @Playfield.id()
              width: 180
            remainingArea:
              contentComponentId: @Parts.id()
          
          when Pinball.GameManager.Modes.Play
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
