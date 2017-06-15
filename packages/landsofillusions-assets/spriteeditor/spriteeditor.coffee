AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor extends AM.Component
  @register 'LandsOfIllusions.Assets.SpriteEditor'

  constructor: ->
    super

    @sprite = new ReactiveField null
    @pixelCanvas = new ReactiveField null
    @navigator = new ReactiveField null
    @palette = new ReactiveField null
    @assetsList = new ReactiveField null
    @assetInfo = new ReactiveField null
    @materials = new ReactiveField null
    @tools = new ReactiveField null
    @toolbox = new ReactiveField null
    @shadingSphere = new ReactiveField null

    @lightDirection = new ReactiveField new THREE.Vector3(0, 0, -1).normalize()

    @spriteId = new ComputedField =>
      FlowRouter.getParam 'spriteId'

    @spriteData = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId
      
    @paletteId = new ComputedField =>
      # Minimize reactivity to only palette changes.
      LOI.Assets.Sprite.documents.findOne(@spriteId(),
        fields:
          palette: 1
      )?.palette?._id

    @activeTool = new ReactiveField null

  onCreated: ->
    super

    $('html').addClass('asset-editor')

    # Initialize components.
    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      lightDirection: @lightDirection

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      initialCameraScale: 8
      activeTool: @activeTool
      drawComponents: => [
        @sprite()
      ]
        
    @assetsList new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Sprite
      getAssetId: @spriteId
      setAssetId: (spriteId) =>
        FlowRouter.setParams {spriteId}

    @navigator new LOI.Assets.Components.Navigator
      camera: @pixelCanvas().camera

    @palette new LOI.Assets.Components.Palette
      paletteId: @paletteId
      materials: @materials

    @assetInfo new LOI.Assets.Components.AssetInfo
      documentClass: LOI.Assets.Sprite
      assetId: @spriteId
      getPaletteId: @paletteId
      setPaletteId: (paletteId) =>
        LOI.Assets.Sprite.update @spriteId(), $set: palette: _id: paletteId

    @materials new LOI.Assets.Components.Materials
      assetId: @spriteId
      documentClass: LOI.Assets.Sprite
      palette: @palette

    @toolbox new LOI.Assets.Components.Toolbox
      tools: @tools
      activeTool: @activeTool
      
    @shadingSphere new LOI.Assets.Components.ShadingSphere
      palette: @palette
      materials: @materials
      lightDirection: @lightDirection
      radius: => 20

    # Create tools.
    toolClasses = [
      @constructor.Tools.Pencil
      @constructor.Tools.Eraser
      @constructor.Tools.ColorFill
      @constructor.Tools.ColorPicker
    ]

    tools = for toolClass in toolClasses
      new toolClass
        editor: => @
          
    @tools tools

    @activeTool tools[0]

  onDestroyed: ->
    super

    $('html').removeClass('asset-editor')
