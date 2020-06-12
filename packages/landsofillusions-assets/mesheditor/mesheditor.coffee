AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor extends LOI.Assets.Editor
  @id: -> 'LandsOfIllusions.Assets.MeshEditor'
  @register @id()

  @defaultInterfaceData: ->
    # Operators

    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()

    operators = {}

    # Components

    components =
      "#{_.snakeCase LOI.Assets.MeshEditor.Tools.Pencil.id()}":
        fractionalPerfectLines: true
        drawPreview: true

      "#{_.snakeCase LOI.Assets.MeshEditor.Tools.ColorFill.id()}":
        cornerNeighbors: true

      "#{_.snakeCase LOI.Assets.SpriteEditor.Helpers.Brush.id()}":
        round: true

      "#{_.snakeCase LOI.Assets.SpriteEditor.Helpers.LightDirection.id()}":
        new THREE.Vector3(2, -4, -3).normalize().toObject()

      "#{_.snakeCase LOI.Assets.SpriteEditor.ShadingSphere.id()}":
        radius: 30
        angleSnap: 45

      "#{_.snakeCase LOI.Assets.MeshEditor.MeshCanvas.id()}":
        components: [
        ]
        
      "#{_.snakeCase LOI.Assets.SpriteEditor.PixelCanvas.id()}":
        initialCameraScale: 2
        components: [
          LOI.Assets.SpriteEditor.Helpers.SafeArea.id()
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
          LOI.Assets.Editor.Actions.Import.id()
          null
          LOI.Assets.MeshEditor.Actions.Save.id()
          LOI.Assets.Editor.Actions.Export.id()
          LOI.Assets.Editor.Actions.Close.id()
          LOI.Assets.Editor.Actions.Duplicate.id()
          LOI.Assets.Editor.Actions.Delete.id()
        ]
      ,
        caption: 'Edit'
        items: [
          LOI.Assets.MeshEditor.Actions.Undo.id()
          LOI.Assets.MeshEditor.Actions.Redo.id()
          null
          LOI.Assets.SpriteEditor.Actions.FlipHorizontal.id()
          null
          LOI.Assets.Editor.Actions.Clear.id()
          LOI.Assets.MeshEditor.Actions.RecomputeMesh.id()
        ]
      ,
        caption: 'View'
        items: [
          LOI.Assets.SpriteEditor.Actions.ZoomIn.id()
          LOI.Assets.SpriteEditor.Actions.ZoomOut.id()
          LOI.Assets.MeshEditor.Actions.ResetCamera.id()
          null
          LOI.Assets.MeshEditor.Actions.IncreaseExposure.id()
          LOI.Assets.MeshEditor.Actions.DecreaseExposure.id()
          LOI.Assets.MeshEditor.Actions.ResetExposure.id()
          null
          LOI.Assets.SpriteEditor.Actions.ShowPixelGrid.id()
          LOI.Assets.MeshEditor.Actions.ShowPlaneGrid.id()
          LOI.Assets.SpriteEditor.Actions.ShowLandmarks.id()
          LOI.Assets.SpriteEditor.Actions.ShowSafeArea.id()
          LOI.Assets.MeshEditor.Actions.ShowEdges.id()
          LOI.Assets.MeshEditor.Actions.ShowHorizon.id()
          LOI.Assets.MeshEditor.Actions.ShowSourceImage.id()
          LOI.Assets.MeshEditor.Actions.ShowPixelRender.id()
          null
          LOI.Assets.SpriteEditor.Actions.PaintNormals.id()
          LOI.Assets.MeshEditor.Actions.DebugMode.id()
        ]
      ,
        caption: 'Scene'
        items: [
          LOI.Assets.MeshEditor.Actions.ShadowsEnabled.id()
          LOI.Assets.MeshEditor.Actions.SmoothShadingEnabled.id()
          LOI.Assets.MeshEditor.Actions.PBREnabled.id()
        ]
      ,
        caption: 'Tools'
        items: [
          LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease.id()
          LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease.id()
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
        LOI.Assets.MeshEditor.Tools.Translate.id()
        LOI.Assets.MeshEditor.Tools.Pencil.id()
        LOI.Assets.MeshEditor.Tools.Eraser.id()
        LOI.Assets.MeshEditor.Tools.ColorFill.id()
        LOI.Assets.MeshEditor.Tools.ClusterPicker.id()
        LOI.Assets.MeshEditor.Tools.MoveCamera.id()
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
                    contentComponentId: LOI.Assets.MeshEditor.Navigator.id()
                  ,
                    name: 'File info'
                    contentComponentId: LOI.Assets.SpriteEditor.AssetInfo.id()
                  ,
                    name: 'Objects'
                    contentComponentId: LOI.Assets.MeshEditor.Objects.id()
                  ,
                    name: 'References'
                    contentComponentId: LOI.Assets.Editor.References.id()
                  ,
                    name: 'Environments'
                    contentComponentId: LOI.Assets.SceneEditor.Environments.id()
                    active: true
                  ]
                remainingArea:
                  type: FM.SplitView.id()
                  dockSide: FM.SplitView.DockSide.Top
                  mainArea:
                    type: FM.TabbedView.id()
                    height: 80
                    tabs: [
                      name: 'Layers'
                      contentComponentId: LOI.Assets.MeshEditor.Layers.id()
                      active: true
                    ,
                      name: 'Landmarks'
                      contentComponentId: LOI.Assets.MeshEditor.Landmarks.id()
                    ,
                      name: 'Camera angles'
                      contentComponentId: LOI.Assets.MeshEditor.CameraAngles.id()
                    ]
                  remainingArea:
                    type: FM.TabbedView.id()
                    tabs: [
                      name: 'Palette'
                      contentComponentId: LOI.Assets.SpriteEditor.Palette.id()
                      active: true
                    ,
                      name: 'Materials'
                      contentComponentId: LOI.Assets.MeshEditor.Materials.id()
                    ,
                      name: 'Shading'
                      contentComponentId: LOI.Assets.SpriteEditor.ShadingSphere.id()
                    ,
                      name: 'Camera'
                      contentComponentId: LOI.Assets.MeshEditor.CameraAngle.id()
                    ,
                      name: 'Cluster'
                      contentComponentId: LOI.Assets.MeshEditor.Cluster.id()
                    ]

              remainingArea:
                type: FM.EditorView.id()
                editor:
                  contentComponentId: LOI.Assets.MeshEditor.MeshCanvas.id()

    shortcuts =
      currentMappingId: 'default'
      default:
        name: "Default"
        mapping: @defaultShortcutsMapping()

    # Return combined interface data.
    {activeToolId, operators, components, layouts, shortcuts}

  @defaultShortcutsMapping: ->
    isMacOS = AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS

    # Mesh editor uses all default and sprite editor shortcuts.
    _.extend super(arguments...), LOI.Assets.SpriteEditor.defaultShortcutsMapping(),
      # Actions
      "#{LOI.Assets.MeshEditor.Actions.ShowPlaneGrid.id()}": commandOrControl: true, key: AC.Keys.semicolon
      "#{LOI.Assets.MeshEditor.Actions.ShowEdges.id()}": commandOrControl: true, shift: true, key: AC.Keys.e
      "#{LOI.Assets.MeshEditor.Actions.ShowHorizon.id()}": commandOrControl: true, shift: true, key: AC.Keys.h
      "#{LOI.Assets.MeshEditor.Actions.ShowSourceImage.id()}": commandOrControl: true, shift: true, key: AC.Keys.s
      "#{LOI.Assets.MeshEditor.Actions.ShowPixelRender.id()}": commandOrControl: true, shift: true, key: AC.Keys.p
      "#{LOI.Assets.MeshEditor.Actions.DebugMode.id()}": commandOrControl: true, shift: true, key: AC.Keys.d
      "#{LOI.Assets.Editor.Actions.Undo.id()}": null
      "#{LOI.Assets.Editor.Actions.Redo.id()}": null
      "#{LOI.Assets.MeshEditor.Actions.Undo.id()}": commandOrControl: true, key: AC.Keys.z
      "#{LOI.Assets.MeshEditor.Actions.Redo.id()}": if isMacOS then command: true, shift: true, key: AC.Keys.z else control: true, key: AC.Keys.y
      "#{LOI.Assets.MeshEditor.Actions.Save.id()}": commandOrControl: true, key: AC.Keys.s
      "#{LOI.Assets.MeshEditor.Actions.ResetCamera.id()}": key: AC.Keys.graveAccent
      "#{LOI.Assets.MeshEditor.Actions.IncreaseExposure.id()}": shift: true, key: AC.Keys.equalSign, keyLabel: '+'
      "#{LOI.Assets.MeshEditor.Actions.DecreaseExposure.id()}": shift: true, key: AC.Keys.dash
      "#{LOI.Assets.MeshEditor.Actions.ResetExposure.id()}": shift: true, key: AC.Keys['0']

      # Tools
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": null
      "#{LOI.Assets.MeshEditor.Tools.ClusterPicker.id()}": [{key: AC.Keys.i, holdKey: AC.Keys.alt}, {holdKey: AC.Keys.c}]
      "#{LOI.Assets.MeshEditor.Tools.MoveCamera.id()}": key: AC.Keys.m
      "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": null
      "#{LOI.Assets.MeshEditor.Tools.Pencil.id()}": key: AC.Keys.b
      "#{LOI.Assets.SpriteEditor.Tools.Eraser.id()}": null
      "#{LOI.Assets.MeshEditor.Tools.Eraser.id()}": key: AC.Keys.e
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": null
      "#{LOI.Assets.MeshEditor.Tools.ColorFill.id()}": key: AC.Keys.g
      "#{LOI.Assets.MeshEditor.Tools.Translate.id()}": key: AC.Keys.v

  constructor: ->
    super arguments...

    @documentClass = LOI.Assets.Mesh
    @assetClassName = @documentClass.className

    # Pretend to be the global adventure instance.
    LOI.adventure = @

  onCreated: ->
    super arguments...

    # Subscribe to all character part templates.
    types = LOI.Character.Part.allPartTypeIds()

    LOI.Character.Part.Template.forTypes.subscribe @, types

  onRendered: ->
    super arguments...

    editorView = @interface.allChildComponentsOfType(FM.EditorView)[0]
    editorView.addFile id, LOI.Assets.Mesh.id() for id in []

  currentScenes: -> []
