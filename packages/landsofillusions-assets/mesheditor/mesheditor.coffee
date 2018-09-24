AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor'

  constructor: ->
    super

    @sprite = new ReactiveField null
    @pixelCanvas = new ReactiveField null
    @meshCanvas = new ReactiveField null
    @navigator = new ReactiveField null
    @palette = new ReactiveField null
    @assetsList = new ReactiveField null
    @assetInfo = new ReactiveField null
    @materials = new ReactiveField null
    @landmarks = new ReactiveField null
    @cameraAngles = new ReactiveField null
    @tools = new ReactiveField null
    @actions = new ReactiveField null
    @toolbox = new ReactiveField null
    @shadingSphere = new ReactiveField null

    @lightDirection = new ReactiveField new THREE.Vector3(0, 0, -1).normalize()
    @paintNormals = new ReactiveField false
    @symmetryXOrigin = new ReactiveField null
    
    @pixelGridEnabled = new ReactiveField true
    @planeGridEnabled = new ReactiveField true

    @meshId = new ComputedField =>
      AB.Router.getParameter 'meshId'

    @meshData = new ComputedField =>
      return unless meshId = @meshId()

      LOI.Assets.Mesh.forId.subscribe meshId
      LOI.Assets.Mesh.documents.findOne meshId

    @cameraAngleIndex = new ReactiveField null

    @spriteId = new ComputedField =>
      return unless meshData = @meshData()
      return unless cameraAngle = meshData.cameraAngles?[@cameraAngleIndex()]
      cameraAngle.sprite._id

    @spriteData = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId
      
    @paletteId = new ComputedField =>
      # Minimize reactivity to only palette changes.
      LOI.Assets.Mesh.documents.findOne(@meshId(),
        fields:
          palette: 1
      )?.palette?._id

    @activeTool = new ReactiveField null

    @canvasFocused = new ReactiveField true

  onCreated: ->
    super

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
      gridEnabled: @pixelGridEnabled

    @meshCanvas new @constructor.MeshCanvas
      gridEnabled: @planeGridEnabled

    setAssetId = (meshId) =>
      AB.Router.setParameters {meshId}
        
    @assetsList new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Mesh
      getAssetId: @meshId
      setAssetId: setAssetId

    @navigator new LOI.Assets.Components.Navigator
      camera: @pixelCanvas().camera
      enabled: @canvasFocused

    @palette new LOI.Assets.Components.Palette
      paletteId: @paletteId
      materials: @materials

    @assetInfo new LOI.Assets.Components.AssetInfo
      documentClass: LOI.Assets.Mesh
      getAssetId: @meshId
      setAssetId: setAssetId
      getPaletteId: @paletteId
      setPaletteId: (paletteId) =>
        LOI.Assets.Mesh.update @meshId(), $set: palette: _id: paletteId

    @materials new LOI.Assets.Components.Materials
      assetId: @meshId
      documentClass: LOI.Assets.Mesh
      palette: @palette

    @landmarks new LOI.Assets.Components.Landmarks
      assetId: @meshId
      documentClass: LOI.Assets.Mesh
      pixelCanvas: @pixelCanvas

    @cameraAngles new LOI.Assets.MeshEditor.CameraAngles
      meshId: @meshId

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
      LOI.Assets.SpriteEditor.Tools.Pencil
      LOI.Assets.SpriteEditor.Tools.Eraser
      LOI.Assets.SpriteEditor.Tools.ColorFill
      LOI.Assets.SpriteEditor.Tools.ColorPicker
      LOI.Assets.SpriteEditor.Tools.PaintNormals
      LOI.Assets.SpriteEditor.Tools.Symmetry
      LOI.Assets.MeshEditor.Tools.PixelGrid
      LOI.Assets.MeshEditor.Tools.PlaneGrid
    ]

    tools = for toolClass in toolClasses
      new toolClass
        editor: => @
          
    @tools tools

  onDestroyed: ->
    super

    $('html').removeClass('asset-editor')

  toolClass: ->
    return unless tool = @activeTool()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  events: ->
    super.concat
      'focus input': @onFocusInput
      'blur input': @onBlurInput

  onFocusInput: (event) ->
    @canvasFocused false

  onBlurInput: (event) ->
    @canvasFocused true
