AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor extends LOI.Assets.SpriteEditor
  @register @id()

  @defaultInterfaceData: ->
    # Operators

    activeToolId = @Tools.Arrow.id()

    operators = {}

    # Content Components

    components =
      "#{_.snakeCase LOI.Assets.SpriteEditor.ShadingSphere.id()}":
        radius: 30

      "#{_.snakeCase LOI.Assets.SpriteEditor.PixelCanvas.id()}":
        initialCameraScale: 8
        components: [
          LOI.Assets.SpriteEditor.Helpers.Landmarks.id()
        ]

    # Layouts

    menu =
      type: FM.Menu.id()
      items: [
        caption: 'Sprite Editor'
      ,
        caption: 'File'
        items: [
          LOI.Assets.Editor.Actions.New.id()
          LOI.Assets.Editor.Actions.Open.id()
          null
          LOI.Assets.Editor.Actions.Close.id()
          LOI.Assets.Editor.Actions.Duplicate.id()
          LOI.Assets.Editor.Actions.Delete.id()
        ]
      ,
        caption: 'Edit'
        items: [
          LOI.Assets.Editor.Actions.Undo.id()
          LOI.Assets.Editor.Actions.Redo.id()
          null
          @Actions.FlipHorizontal.id()
          null
          LOI.Assets.Editor.Actions.Clear.id()
        ]
      ,
        caption: 'View'
        items: [
          @Actions.ZoomIn.id()
          @Actions.ZoomOut.id()
          null
          @Actions.ShowGrid.id()
          @Actions.ShowLandmarks.id()
          @Actions.PaintNormals.id()
        ]
      ,
        caption: 'Window'
      ]

    toolbox =
      type: FM.Toolbox.id()
      width: 20
      widthStep: 20
      minWidth: 20
      tools: [
        @Tools.Arrow.id()
        @Tools.Pencil.id()
        @Tools.Eraser.id()
        @Tools.ColorFill.id()
        @Tools.ColorPicker.id()
      ]

    layouts =
      currentLayoutId: 'main'
      main:
        name: 'Main'
        applicationArea:
          type: FM.SplitView.id()
          fixed: true
          mainArea: menu
          dockSide: FM.SplitView.DockSide.Top
          remainingArea:
            type: FM.SplitView.id()
            dockSide: FM.SplitView.DockSide.Left
            mainArea: toolbox
            remainingArea:
              type: FM.SplitView.id()
              dockSide: FM.SplitView.DockSide.Right
              mainArea:
                type: FM.SplitView.id()
                dockSide: FM.SplitView.DockSide.Top
                width: 150
                mainArea:
                  type: FM.TabbedView.id()
                  height: 50
                  tabs: [
                    name: 'Navigator'
                    contentComponentId: LOI.Assets.SpriteEditor.Navigator.id()
                    active: true
                  ,
                    name: 'File info'
                    contentComponentId: LOI.Assets.SpriteEditor.AssetInfo.id()
                  ]
                remainingArea:
                  type: FM.SplitView.id()
                  dockSide: FM.SplitView.DockSide.Top
                  mainArea:
                    type: FM.TabbedView.id()
                    height: 100
                    tabs: [
                      name: 'Landmarks'
                      contentComponentId: LOI.Assets.Editor.Landmarks.id()
                      active: true
                    ]
                  remainingArea:
                    type: FM.TabbedView.id()
                    tabs: [
                      name: 'Palette'
                      contentComponentId: LOI.Assets.SpriteEditor.Palette.id()
                    ,
                      name: 'Materials'
                      contentComponentId: LOI.Assets.SpriteEditor.Materials.id()
                    ,
                      name: 'Shading'
                      contentComponentId: LOI.Assets.SpriteEditor.ShadingSphere.id()
                      active: true
                    ]

              remainingArea:
                type: FM.EditorView.id()
                editor:
                  contentComponentId: LOI.Assets.SpriteEditor.PixelCanvas.id()

    # Shortcuts

    isMacOS = AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS

    shortcuts =
      currentMappingId: 'default'
      default:
        name: "Default"
        mapping:
          # Actions
          "#{LOI.Assets.Editor.Actions.New.id()}": commandOrControl: true, key: AC.Keys.n
          "#{LOI.Assets.Editor.Actions.Open.id()}": commandOrControl: true, key: AC.Keys.o
          "#{LOI.Assets.Editor.Actions.Close.id()}": commandOrControl: true, key: AC.Keys.w
          "#{LOI.Assets.Editor.Actions.Undo.id()}": commandOrControl: true, key: AC.Keys.z
          "#{LOI.Assets.Editor.Actions.Redo.id()}": if isMacOS then command: true, shift: true, key: AC.Keys.z else control: true, key: AC.Keys.y
          "#{@Actions.PaintNormals.id()}": key: AC.Keys.n
          "#{@Actions.Symmetry.id()}": key: AC.Keys.s
          "#{@Actions.ZoomIn.id()}": [{key: AC.Keys.equalSign, keyLabel: '+'}, {commandOrControl: true, key: AC.Keys.equalSign}]
          "#{@Actions.ZoomOut.id()}": [{key: AC.Keys.dash}, {commandOrControl: true, key: AC.Keys.dash}]
          "#{@Actions.ShowGrid.id()}":commandOrControl: true, key: AC.Keys.singleQuote
          "#{@Actions.ShowLandmarks.id()}":commandOrControl: true, shift: true, key: AC.Keys.l

          # Tools
          "#{@Tools.Arrow.id()}": key: AC.Keys.escape
          "#{@Tools.ColorFill.id()}": key: AC.Keys.g
          "#{@Tools.ColorPicker.id()}": key: AC.Keys.i, holdKey: AC.Keys.alt
          "#{@Tools.Eraser.id()}": key: AC.Keys.e
          "#{@Tools.Pencil.id()}": key: AC.Keys.b

    # Return combined interface data.
    {activeToolId, operators, components, layouts, shortcuts}
