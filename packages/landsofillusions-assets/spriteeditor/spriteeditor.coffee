AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor extends LOI.Assets.Editor
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor'
  @register @id()

  @defaultInterfaceData: ->
    # Operators

    active = true
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()

    # Content Components

    components =
      "#{_.snakeCase LOI.Assets.SpriteEditor.Tools.Pencil.id()}":
        fractionalPerfectLines: true
        drawPreview: true

      "#{_.snakeCase LOI.Assets.SpriteEditor.Helpers.Brush.id()}":
        round: true

      "#{_.snakeCase LOI.Assets.SpriteEditor.ShadingSphere.id()}":
        radius: 30
        angleSnap: 30

      "#{_.snakeCase LOI.Assets.SpriteEditor.PixelCanvas.id()}":
        initialCameraScale: 8
        scrollingEnabled: true
        components: [
          LOI.Assets.SpriteEditor.Helpers.SafeArea.id()
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
          LOI.Assets.Editor.Actions.Import.id()
          null
          LOI.Assets.Editor.Actions.Close.id()
          LOI.Assets.Editor.Actions.Export.id()
          LOI.Assets.Editor.Actions.Duplicate.id()
          LOI.Assets.Editor.Actions.Delete.id()
        ]
      ,
        caption: 'Edit'
        items: [
          LOI.Assets.Editor.Actions.Undo.id()
          LOI.Assets.Editor.Actions.Redo.id()
          null
          LOI.Assets.SpriteEditor.Actions.Resize.id()
          LOI.Assets.SpriteEditor.Actions.FlipHorizontal.id()
          LOI.Assets.SpriteEditor.Actions.GenerateMipmaps.id()
          null
          LOI.Assets.Editor.Actions.Clear.id()
        ]
      ,
        caption: 'View'
        items: [
          LOI.Assets.SpriteEditor.Actions.ZoomIn.id()
          LOI.Assets.SpriteEditor.Actions.ZoomOut.id()
          null
          LOI.Assets.SpriteEditor.Actions.Rot8Left.id()
          LOI.Assets.SpriteEditor.Actions.Rot8Right.id()
          null
          LOI.Assets.SpriteEditor.Actions.ShowPixelGrid.id()
          LOI.Assets.SpriteEditor.Actions.ShowLandmarks.id()
          LOI.Assets.SpriteEditor.Actions.ShowSafeArea.id()
          null
          LOI.Assets.SpriteEditor.Actions.ShowShading.id()
          LOI.Assets.SpriteEditor.Actions.PaintNormals.id()
        ]
      ,
        caption: 'Tools'
        items: [
          LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease.id()
          LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease.id()
          null
          LOI.Assets.SpriteEditor.Actions.IgnoreNormals.id()
        ]
      ,
        caption: 'Window'
        items: [
          LOI.Assets.Editor.Actions.PersistEditorsInterface.id()
          LOI.Assets.Editor.Actions.ResetInterface.id()
        ]
      ]

    toolbox =
      type: FM.Toolbox.id()
      width: 20
      widthStep: 20
      minWidth: 20
      tools: [
        LOI.Assets.Editor.Tools.Arrow.id()
        LOI.Assets.SpriteEditor.Tools.Translate.id()
        LOI.Assets.SpriteEditor.Tools.Pencil.id()
        LOI.Assets.SpriteEditor.Tools.Eraser.id()
        LOI.Assets.SpriteEditor.Tools.Smooth.id()
        LOI.Assets.SpriteEditor.Tools.ColorFill.id()
        LOI.Assets.SpriteEditor.Tools.ColorPicker.id()
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
                  height: 80
                  tabs: [
                    name: 'Navigator'
                    contentComponentId: LOI.Assets.SpriteEditor.Navigator.id()
                    active: true
                  ,
                    name: 'File info'
                    contentComponentId: LOI.Assets.Editor.AssetInfo.id()
                  ]
                remainingArea:
                  type: FM.SplitView.id()
                  dockSide: FM.SplitView.DockSide.Top
                  mainArea:
                    type: FM.TabbedView.id()
                    height: 100
                    tabs: [
                      name: 'Layers'
                      contentComponentId: LOI.Assets.SpriteEditor.Layers.id()
                      active: true
                    ,
                      name: 'Landmarks'
                      contentComponentId: LOI.Assets.SpriteEditor.Landmarks.id()
                    ]
                  remainingArea:
                    type: FM.TabbedView.id()
                    tabs: [
                      name: 'Palette'
                      contentComponentId: LOI.Assets.SpriteEditor.Palette.id()
                      active: true
                    ,
                      name: 'Materials'
                      contentComponentId: LOI.Assets.Editor.Materials.id()
                    ,
                      name: 'Shading'
                      contentComponentId: LOI.Assets.SpriteEditor.ShadingSphere.id()
                    ]

              remainingArea:
                type: FM.EditorView.id()
                editor:
                  contentComponentId: LOI.Assets.SpriteEditor.PixelCanvas.id()

    shortcuts =
      currentMappingId: 'default'
      default:
        name: "Default"
        mapping: @defaultShortcutsMapping()

    # Return combined interface data.
    {active, activeToolId, components, layouts, shortcuts}

  @defaultShortcutsMapping: ->
    _.extend super(arguments...),
      # Actions
      "#{LOI.Assets.SpriteEditor.Actions.ShowShading.id()}": commandOrControl: true, shift: true, key: AC.Keys.s
      "#{LOI.Assets.SpriteEditor.Actions.PaintNormals.id()}": key: AC.Keys.n
      "#{LOI.Assets.SpriteEditor.Actions.IgnoreNormals.id()}": shift: true, key: AC.Keys.n
      "#{LOI.Assets.SpriteEditor.Actions.Symmetry.id()}": key: AC.Keys.s
      "#{LOI.Assets.SpriteEditor.Actions.ZoomIn.id()}": [{key: AC.Keys.equalSign, keyLabel: '+'}, {commandOrControl: true, key: AC.Keys.equalSign}]
      "#{LOI.Assets.SpriteEditor.Actions.ZoomOut.id()}": [{key: AC.Keys.dash}, {commandOrControl: true, key: AC.Keys.dash}]
      "#{LOI.Assets.SpriteEditor.Actions.ShowPixelGrid.id()}": commandOrControl: true, key: AC.Keys.singleQuote
      "#{LOI.Assets.SpriteEditor.Actions.ShowLandmarks.id()}": commandOrControl: true, shift: true, key: AC.Keys.l
      "#{LOI.Assets.SpriteEditor.Actions.ShowSafeArea.id()}": commandOrControl: true, shift: true, key: AC.Keys.a
      "#{LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease.id()}": [{key: AC.Keys.openBracket}, {key: AC.Keys.openBracket, commandOrControl: true}]
      "#{LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease.id()}": [{key: AC.Keys.closeBracket}, {key: AC.Keys.closeBracket, commandOrControl: true}]
      "#{LOI.Assets.SpriteEditor.Actions.Rot8Left.id()}": key: AC.Keys.comma
      "#{LOI.Assets.SpriteEditor.Actions.Rot8Right.id()}": key: AC.Keys.period

      # Tools
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": key: AC.Keys.g
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": [{key: AC.Keys.i, holdKey: AC.Keys.alt}, {holdKey: AC.Keys.c}]
      "#{LOI.Assets.SpriteEditor.Tools.Eraser.id()}": key: AC.Keys.e
      "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": key: AC.Keys.b
      "#{LOI.Assets.SpriteEditor.Tools.Translate.id()}": key: AC.Keys.v
      "#{LOI.Assets.SpriteEditor.Tools.Smooth.id()}": key: AC.Keys.s

  constructor: ->
    super arguments...

    @documentClass = LOI.Assets.Sprite
    @assetClassName = @documentClass.className

  onRendered: ->
    super arguments...

    editorView = @interface.allChildComponentsOfType(FM.EditorView)[0]
    editorView.addFile id, LOI.Assets.Sprite.id() for id in []
