AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor extends AM.Component
  @register 'LandsOfIllusions.Assets.SpriteEditor'

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
    @tools = new ReactiveField null
    @actions = new ReactiveField null
    @toolbox = new ReactiveField null
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

    @activeTool = new ReactiveField null

    @canvasFocused = new ReactiveField true

  onCreated: ->
    super arguments...

    $('html').addClass('asset-editor')

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

    @materials new LOI.Assets.Components.Materials
      assetId: @spriteId
      documentClass: LOI.Assets.Sprite
      palette: @palette

    @landmarks new LOI.Assets.Components.Landmarks
      assetId: @spriteId
      documentClass: LOI.Assets.Sprite
      pixelCanvas: @pixelCanvas

    @toolbox new LOI.Assets.Components.Toolbox
      tools: @tools
      activeTool: @activeTool
      actions: @actions
      enabled: @canvasFocused

    @shadingSphere new LOI.Assets.Components.ShadingSphere
      palette: @palette
      materials: @materials
      lightDirection: @lightDirection
      visualizeNormals: @paintNormals
      radius: => 30

    # Create tools.
    toolClasses = [
      @constructor.Tools.Pencil
      @constructor.Tools.Eraser
      @constructor.Tools.ColorFill
      @constructor.Tools.ColorPicker
      @constructor.Tools.PaintNormals
      @constructor.Tools.Symmetry
      @constructor.Tools.Undo
      @constructor.Tools.Redo
    ]

    tools = for toolClass in toolClasses
      new toolClass
        editor: => @
          
    @tools tools

  onDestroyed: ->
    super arguments...

    $('html').removeClass('asset-editor')

  toolClass: ->
    return unless tool = @activeTool()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '
    
  events: ->
    super(arguments...).concat
      'focus input': @onFocusInput
      'blur input': @onBlurInput

  onFocusInput: (event) ->
    @canvasFocused false

  onBlurInput: (event) ->
    @canvasFocused true
