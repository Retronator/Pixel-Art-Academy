AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor extends LOI.Assets.Editor
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor'
  @register @id()

  constructor: ->
    super arguments...

    @documentClass = LOI.Assets.Sprite
    @assetClassName = @documentClass.className

  @defaultInterfaceData: ->
    # Operators

    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()

    # Content Components

    components =
      "#{_.snakeCase LOI.Assets.SpriteEditor.Tools.Pencil.id()}":
        drawPreview: true

      "#{_.snakeCase LOI.Assets.SpriteEditor.ShadingSphere.id()}":
        radius: 30

      "#{_.snakeCase LOI.Assets.SpriteEditor.PixelCanvas.id()}":
        initialCameraScale: 8
        components: [
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
          LOI.Assets.SpriteEditor.Actions.FlipHorizontal.id()
          null
          LOI.Assets.Editor.Actions.Clear.id()
        ]
      ,
        caption: 'View'
        items: [
          LOI.Assets.SpriteEditor.Actions.ZoomIn.id()
          LOI.Assets.SpriteEditor.Actions.ZoomOut.id()
          null
          LOI.Assets.SpriteEditor.Actions.ShowPixelGrid.id()
          LOI.Assets.SpriteEditor.Actions.ShowLandmarks.id()
          null
          LOI.Assets.SpriteEditor.Actions.PaintNormals.id()
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
        LOI.Assets.Editor.Tools.Arrow.id()
        LOI.Assets.SpriteEditor.Tools.Translate.id()
        LOI.Assets.SpriteEditor.Tools.Pencil.id()
        LOI.Assets.SpriteEditor.Tools.Eraser.id()
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
                    contentComponentId: LOI.Assets.SpriteEditor.AssetInfo.id()
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
                      contentComponentId: LOI.Assets.Editor.Landmarks.id()
                    ]
                  remainingArea:
                    type: FM.TabbedView.id()
                    tabs: [
                      name: 'Palette'
                      contentComponentId: LOI.Assets.SpriteEditor.Palette.id()
                    ,
                      name: 'Materials'
                      contentComponentId: LOI.Assets.Editor.Materials.id()
                    ,
                      name: 'Shading'
                      contentComponentId: LOI.Assets.SpriteEditor.ShadingSphere.id()
                      active: true
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
    {activeToolId, components, layouts, shortcuts}

  @defaultShortcutsMapping: ->
    _.extend super(arguments...),
      # Actions
      "#{LOI.Assets.SpriteEditor.Actions.PaintNormals.id()}": key: AC.Keys.n
      "#{LOI.Assets.SpriteEditor.Actions.Symmetry.id()}": key: AC.Keys.s
      "#{LOI.Assets.SpriteEditor.Actions.ZoomIn.id()}": [{key: AC.Keys.equalSign, keyLabel: '+'}, {commandOrControl: true, key: AC.Keys.equalSign}]
      "#{LOI.Assets.SpriteEditor.Actions.ZoomOut.id()}": [{key: AC.Keys.dash}, {commandOrControl: true, key: AC.Keys.dash}]
      "#{LOI.Assets.SpriteEditor.Actions.ShowPixelGrid.id()}":commandOrControl: true, key: AC.Keys.singleQuote
      "#{LOI.Assets.SpriteEditor.Actions.ShowLandmarks.id()}":commandOrControl: true, shift: true, key: AC.Keys.l

      # Tools
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": key: AC.Keys.g
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": key: AC.Keys.i, holdKey: AC.Keys.alt
      "#{LOI.Assets.SpriteEditor.Tools.Eraser.id()}": key: AC.Keys.e
      "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": key: AC.Keys.b
      "#{LOI.Assets.SpriteEditor.Tools.Translate.id()}": key: AC.Keys.v

  onRendered: ->
    super arguments...

    editorView = @interface.allChildComponentsOfType(FM.EditorView)[0]
    editorView.addFile id, LOI.Assets.Sprite.id() for id in ['CX9JyXqW2mZduyajR', 'KqL3XmQ7MikndhWxN', 'ZZefMqG8h5gCwQztD']
