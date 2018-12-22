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
    menu =
      type: FM.Menu.id()
      items: [
        caption: 'Sprite Editor'
      ,
        caption: 'File'
      ,
        caption: 'Edit'
        items: [
          @Actions.Undo.id()
          @Actions.Redo.id()
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

    layouts:
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
                type: FM.TabbedView.id()
                width: 150
                tabs: [
                  contentComponentId: LOI.Assets.Components.Navigator.id()
                ,
                  contentComponentId: LOI.Assets.Components.AssetInfo.id()
                ]
              remainingArea:
                contentComponentId: LOI.Assets.Components.PixelCanvas.id()

  constructor: ->
    super arguments...

    @sprite = new ReactiveField null
    @pixelCanvas = new ReactiveField null
    @navigator = new ReactiveField null
    @palette = new ReactiveField null
    @assetsList = new ReactiveField null
    @assetInfo = new ReactiveField null
    @materials = new ReactiveField null
    @landmarks = new ReactiveField null
    @shadingSphere = new ReactiveField null

    @lightDirection = new ReactiveField new THREE.Vector3(0, 0, -1).normalize()
    @paintNormals = new ReactiveField false
    @symmetryXOrigin = new ReactiveField null

    @spriteId = new ComputedField =>
      AB.Router.getParameter 'spriteId'

    @spriteData = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, spriteId
      LOI.Assets.Sprite.documents.findOne spriteId
      
    @paletteId = new ComputedField =>
      # Minimize reactivity to only palette changes.
      LOI.Assets.Sprite.documents.findOne(@spriteId(),
        fields:
          palette: 1
      )?.palette?._id

  onCreated: ->
    super arguments...

    # Initialize components.
    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormals

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      initialCameraScale: 8
      activeTool: @activeTool
      lightDirection: @lightDirection
      drawComponents: => [
        @sprite()
        @landmarks()
      ]
      symmetryXOrigin: @symmetryXOrigin

    @interface.registerContentComponent @pixelCanvas()

    setAssetId = (spriteId) =>
      AB.Router.setParameters {spriteId}
        
    @assetsList new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Sprite
      getAssetId: @spriteId
      setAssetId: setAssetId
      subscription: LOI.Assets.Sprite.allGeneric

    @navigator new LOI.Assets.Components.Navigator
      camera: @pixelCanvas().camera
      enabled: @canvasFocused

    @interface.registerContentComponent @navigator()

    @palette new LOI.Assets.Components.Palette
      paletteId: @paletteId
      materials: @materials

    @assetInfo new LOI.Assets.Components.AssetInfo
      documentClass: LOI.Assets.Sprite
      getAssetId: @spriteId
      setAssetId: setAssetId
      getPaletteId: @paletteId
      setPaletteId: (paletteId) =>
        LOI.Assets.Asset.update LOI.Assets.Sprite.className, @spriteId(), $set: palette: _id: paletteId

    @interface.registerContentComponent @assetInfo()

    @materials new LOI.Assets.Components.Materials
      assetId: @spriteId
      documentClass: LOI.Assets.Sprite
      palette: @palette

    @landmarks new LOI.Assets.Components.Landmarks
      assetId: @spriteId
      documentClass: LOI.Assets.Sprite
      pixelCanvas: @pixelCanvas

    @shadingSphere new LOI.Assets.Components.ShadingSphere
      palette: @palette
      materials: @materials
      lightDirection: @lightDirection
      visualizeNormals: @paintNormals
      radius: => 30

    # Create tools.
    toolClasses = [
      @constructor.Tools.Arrow
      @constructor.Tools.Pencil
      @constructor.Tools.Eraser
      @constructor.Tools.ColorFill
      @constructor.Tools.ColorPicker
    ]

    for toolClass in toolClasses
      @interface.registerTool new toolClass
        editor: => @
    
    # Start with the arrow tool.
    @interface.activeTool @interface.getTool @constructor.Tools.Arrow

    # Create actions.
    actionClasses = [
      @constructor.Actions.Undo
      @constructor.Actions.Redo
      @constructor.Actions.FlipHorizontal
      @constructor.Actions.PaintNormals
      @constructor.Actions.Symmetry
    ]

    for actionClass in actionClasses
      @interface.registerAction new actionClass
        editor: => @
