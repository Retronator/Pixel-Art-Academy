AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor extends LOI.Assets.Editor
  @id: -> 'LandsOfIllusions.Assets.MeshEditor'
  @register @id()

  constructor: ->
    super arguments...

    @documentClass = LOI.Assets.Mesh
    @assetClassName = @documentClass.className

  @defaultInterfaceData: ->
    # Operators

    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()

    operators = {}

    # Content Components

    components =
      "#{_.snakeCase LOI.Assets.SpriteEditor.ShadingSphere.id()}":
        radius: 30

      "#{_.snakeCase LOI.Assets.MeshEditor.MeshCanvas.id()}":
        components: [
        ]
        
      "#{_.snakeCase LOI.Assets.SpriteEditor.PixelCanvas.id()}":
        initialCameraScale: 8
        components: [
        ]

    # Layouts

    menu =
      type: FM.Menu.id()
      items: [
        caption: '3D Paint'
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
          LOI.Assets.MeshEditor.Actions.ShowPlaneGrid.id()
          LOI.Assets.SpriteEditor.Actions.ShowLandmarks.id()
          LOI.Assets.MeshEditor.Actions.ShowEdges.id()
          LOI.Assets.MeshEditor.Actions.ShowHorizon.id()
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
                    height: 80
                    tabs: [
                      name: 'Layers'
                      contentComponentId: LOI.Assets.SpriteEditor.Layers.id()
                    ,
                      name: 'Landmarks'
                      contentComponentId: LOI.Assets.Editor.Landmarks.id()
                    ,
                      name: 'Camera angles'
                      contentComponentId: LOI.Assets.MeshEditor.CameraAngles.id()
                      active: true
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
                    ,
                      name: 'Camera'
                      contentComponentId: LOI.Assets.MeshEditor.CameraAngle.id()
                      active: true
                    ]

              remainingArea:
                type: FM.EditorView.id()
                editor:
                  contentComponentId: LOI.Assets.MeshEditor.MeshCanvas.id()

    # Shortcuts

    isMacOS = AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS

    shortcuts =
      currentMappingId: 'default'
      default:
        name: "Default"
        mapping: @defaultShortcutsMapping()

    # Return combined interface data.
    {activeToolId, operators, components, layouts, shortcuts}

  @defaultShortcutsMapping: ->
    # Mesh editor uses all default and sprite editor shortcuts.
    _.extend super(arguments...), LOI.Assets.SpriteEditor.defaultShortcutsMapping(),
      # Actions
      "#{LOI.Assets.MeshEditor.Actions.ShowPlaneGrid.id()}":commandOrControl: true, key: AC.Keys.semicolon

      # Tools
      "#{LOI.Assets.MeshEditor.Tools.ClusterPicker.id()}": key: AC.Keys.i, holdKey: AC.Keys.alt

  onRendered: ->
    super arguments...

    editorView = @interface.allChildComponentsOfType(FM.EditorView)[0]
    editorView.addFile id, LOI.Assets.Mesh.id() for id in ['z3m5euLEC6KHKCZjJ']
