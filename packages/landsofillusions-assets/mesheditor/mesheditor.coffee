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
    @edges = new ReactiveField null
    @horizon = new ReactiveField null
    @pixelCanvas = new ReactiveField null
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
    @sourceImageVisible = new ReactiveField false
    @pixelImageVisible = new ReactiveField true
    @debug = new ReactiveField false

    @currentCluster = new ReactiveField null

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
    super

    $('html').addClass('asset-editor')

    # Initialize components.
    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormals
      
    @edges new @constructor.Edges
      mesh: @mesh

    @horizon new @constructor.Horizon
      currentNormal: => @shadingSphere()?.currentNormal()
      cameraAngle: @cameraAngle

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      initialCameraScale: 8
      activeTool: @activeTool
      lightDirection: @lightDirection
      drawComponents: =>
        return [] unless @sourceImageVisible() and @spriteData()
        
        [
          @sprite()
          @landmarks()
          @edges()
          @horizon()
        ]
        
      symmetryXOrigin: @symmetryXOrigin
      gridEnabled: @pixelGridEnabled

    @mesh new LOI.Assets.Engine.Mesh
      meshData: @meshData
      visualizeNormals: @paintNormals
      sceneManager: => @meshCanvas()?.sceneManager()
      debug: @debug
      currentCluster: @currentCluster

    @meshCanvas new @constructor.MeshCanvas
      pixelCanvas: @pixelCanvas
      gridEnabled: @planeGridEnabled
      cameraAngle: @cameraAngle
      lightDirection: @lightDirection
      currentCluster: @currentCluster
      currentNormal: => @shadingSphere()?.currentNormal()
      drawPixelImage: @pixelImageVisible
      debug: @debug

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
        # Update mesh palette.
        LOI.Assets.Mesh.update @meshId(), $set: palette: _id: paletteId

        # Also update palettes of all sprites.
        return unless cameraAngles = @meshData()?.cameraAngles

        for cameraAngle in cameraAngles when cameraAngle.sprite
          LOI.Assets.Sprite.update cameraAngle.sprite._id, $set: palette: _id: paletteId

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
      @constructor.Tools.ClusterPicker
      @constructor.Tools.MoveCamera
      LOI.Assets.SpriteEditor.Tools.PaintNormals
      LOI.Assets.SpriteEditor.Tools.Symmetry
      @constructor.Tools.PixelGrid
      @constructor.Tools.PlaneGrid
      @constructor.Tools.SourceImage
      @constructor.Tools.PixelImage
      @constructor.Tools.Debug
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
