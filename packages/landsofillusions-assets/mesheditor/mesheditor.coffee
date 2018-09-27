AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor'

  constructor: ->
    super arguments...

    @sprite = new ReactiveField null
    @edges = new ReactiveField null
    @pixelCanvas = new ReactiveField null
    @sourceImageVisible = new ReactiveField true
    @mesh = new ReactiveField null
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

      # Subscribe to the mesh and all its sprites.
      LOI.Assets.Mesh.forId.subscribe meshId
      LOI.Assets.Sprite.forMeshId.subscribe meshId

      return unless meshData = LOI.Assets.Mesh.documents.findOne meshId

      # Refresh to embed all sprites.
      meshData.refresh()

      meshData

    @cameraAngleIndex = new ReactiveField 0
    
    @cameraAngle = new ComputedField =>
      return unless meshData = @meshData()
      meshData.cameraAngles?[@cameraAngleIndex()]

    @spriteData = new ComputedField =>
      @cameraAngle()?.sprite

    @paletteId = new ComputedField =>
      # Minimize reactivity to only palette changes.
      LOI.Assets.Mesh.documents.findOne(@meshId(),
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
      
    @edges new @constructor.Edges
      mesh: @mesh

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      initialCameraScale: 8
      activeTool: @activeTool
      lightDirection: @lightDirection
      drawComponents: =>
        return [] unless @sourceImageVisible()
        
        [
          @sprite()
          @landmarks()
          @edges()
        ]
        
      symmetryXOrigin: @symmetryXOrigin
      gridEnabled: @pixelGridEnabled

    @mesh new LOI.Assets.Engine.Mesh
      meshData: @meshData
      sceneManager: => @meshCanvas()?.sceneManager()

    @meshCanvas new @constructor.MeshCanvas
      pixelCanvas: @pixelCanvas
      gridEnabled: @planeGridEnabled
      cameraAngle: @cameraAngle
      currentNormal: => @shadingSphere()?.currentNormal()
      drawComponents: => [
        mesh()
      ]

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
      cameraAngleIndex: @cameraAngleIndex

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
      LOI.Assets.MeshEditor.Tools.MoveCamera
      LOI.Assets.SpriteEditor.Tools.PaintNormals
      LOI.Assets.SpriteEditor.Tools.Symmetry
      LOI.Assets.MeshEditor.Tools.PixelGrid
      LOI.Assets.MeshEditor.Tools.PlaneGrid
      LOI.Assets.MeshEditor.Tools.SourceImage
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
