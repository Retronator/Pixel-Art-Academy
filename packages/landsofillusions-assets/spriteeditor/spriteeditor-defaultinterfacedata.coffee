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

    contentComponents =
      "#{LOI.Assets.Components.ShadingSphere.id()}":
        radius: 30

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
        ]
      ,
        caption: 'Edit'
        items: [
          LOI.Assets.Editor.Actions.Undo.id()
          LOI.Assets.Editor.Actions.Redo.id()
          null
          @Actions.FlipHorizontal.id()
        ]
      ,
        caption: 'View'
        items: [
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
                  height: 200
                  tabs: [
                    name: 'Navigator'
                    contentComponentId: LOI.Assets.Components.Navigator.id()
                    active: true
                  ,
                    name: 'File info'
                    contentComponentId: LOI.Assets.Components.AssetInfo.id()
                  ,
                    name: 'Landmarks'
                    contentComponentId: LOI.Assets.Components.Landmarks.id()
                  ]
                remainingArea:
                  type: FM.TabbedView.id()
                  tabs: [
                    name: 'Palette'
                    contentComponentId: LOI.Assets.Components.Palette.id()
                    active: true
                  ,
                    name: 'Materials'
                    contentComponentId: LOI.Assets.Components.Materials.id()
                  ,
                    name: 'Shading'
                    contentComponentId: LOI.Assets.Components.ShadingSphere.id()
                  ]

              remainingArea:
                type: FM.EditorView.id()
                editor:
                  contentComponentId: LOI.Assets.Components.PixelCanvas.id()

    # Shortcuts

    isMacOS = AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS

    shortcuts =
      currentMappingId: 'default'
      default:
        name: "Default"
        mapping:
          # Actions
          "#{LOI.Assets.Editor.Actions.Undo.id()}": commandOrControl: true, key: AC.Keys.z
          "#{LOI.Assets.Editor.Actions.Redo.id()}": if isMacOS then command: true, shift: true, key: AC.Keys.z else control: true, key: AC.Keys.y
          "#{@Actions.PaintNormals.id()}": key: AC.Keys.n
          "#{@Actions.Symmetry.id()}": key: AC.Keys.s
          "#{@Actions.ZoomIn.id()}": [{key: AC.Keys.plus}, {commandOrControl: true, key: AC.Keys.plus}]
          "#{@Actions.ZoomOut.id()}": [{key: AC.Keys.minus}, {commandOrControl: true, key: AC.Keys.minus}]

          # Tools
          "#{@Tools.Arrow.id()}": key: AC.Keys.escape
          "#{@Tools.ColorFill.id()}": key: AC.Keys.g
          "#{@Tools.ColorPicker.id()}": key: AC.Keys.i, holdKey: AC.Keys.alt
          "#{@Tools.Eraser.id()}": key: AC.Keys.e
          "#{@Tools.Pencil.id()}": key: AC.Keys.b

    # Return combined interface data.
    {activeToolId, operators, contentComponents, layouts, shortcuts}
