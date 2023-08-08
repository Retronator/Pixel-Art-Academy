AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor extends LOI.Assets.Editor
  @id: -> 'LandsOfIllusions.Assets.AudioEditor'
  @register @id()

  @defaultInterfaceData: ->
    # Operators
    
    active = true
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()

    # Content Components
    
    components =
      "#{_.snakeCase LOI.Assets.AudioEditor.AudioCanvas.id()}":
        initialCameraScale: 1
    
    # Layouts

    menu =
      type: FM.Menu.id()
      items: [
        caption: 'Audio Editor'
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
          LOI.Assets.AudioEditor.Actions.DuplicateNode.id()
        ]
      ,
        caption: 'View'
        items: [
          LOI.Assets.SpriteEditor.Actions.ZoomIn.id()
          LOI.Assets.SpriteEditor.Actions.ZoomOut.id()
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
                    contentComponentId: LOI.Assets.AudioEditor.Navigator.id()
                    active: true
                  ,
                    name: 'File info'
                    contentComponentId: LOI.Assets.Editor.AssetInfo.id()
                  ]
                remainingArea:
                  type: FM.TabbedView.id()
                  tabs: [
                    name: 'Nodes'
                    contentComponentId: LOI.Assets.AudioEditor.NodeLibrary.id()
                    active: true
                  ]

              remainingArea:
                type: FM.SplitView.id()
                dockSide: FM.SplitView.DockSide.Bottom
                mainArea:
                  height: 30
                  type: LOI.Assets.AudioEditor.AdventureView.id()

                remainingArea:
                  type: FM.EditorView.id()
                  editor:
                    contentComponentId: LOI.Assets.AudioEditor.AudioCanvas.id()

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
      "#{LOI.Assets.SpriteEditor.Actions.ZoomIn.id()}": [
        {key: AC.Keys.equalSign, keyLabel: '+'}
        {commandOrControl: true, key: AC.Keys.equalSign}
        {key: AC.Keys.numPlus}
        {key: AC.Keys.t}
      ]
      "#{LOI.Assets.SpriteEditor.Actions.ZoomOut.id()}": [
        {key: AC.Keys.dash}
        {commandOrControl: true, key: AC.Keys.dash}
        {key: AC.Keys.numMinus}
        {key: AC.Keys.r}
      ]
      "#{LOI.Assets.AudioEditor.Actions.DuplicateNode.id()}": [
        {key: AC.Keys.d}
      ]

  constructor: ->
    super arguments...

    @documentClass = LOI.Assets.Audio
    @assetClassName = @documentClass.className

  onRendered: ->
    super arguments...

    editorView = @interface.allChildComponentsOfType(FM.EditorView)[0]
    editorView.addFile id, LOI.Assets.Audio.id() for id in []
