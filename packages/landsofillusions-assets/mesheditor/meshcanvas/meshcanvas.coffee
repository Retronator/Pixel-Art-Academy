AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas extends FM.EditorView.Editor
  # EDITOR FILE DATA
  # cameraAngleIndex: which camera angle to show in this editor
  # edgesEnabled: boolean whether to show edges between clusters
  # horizonEnabled: boolean whether to show the horizon of the plane we're currently painting (based on the normal)
  # pixelRenderEnabled: boolean whether to show the pixel art render instead of the high-res source
  # planeGridEnabled: boolean whether to show the plane of the current cluster
  # sourceImageEnabled: boolean whether to show the source sprite instead of the render
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.MeshCanvas'
  @register @id()
  
  @editorFileDataFieldsWithDefaults: ->
    cameraAngleIndex: 0
    edgesEnabled: false
    edgePixelsEnabled: false
    horizonEnabled: true
    pixelRenderEnabled: true
    planeGridEnabled: true
    sourceImageEnabled: false

  constructor: ->
    super arguments...

    @planeGrid = new ReactiveField null
    @debugRay = new ReactiveField null
    @references = new ReactiveField null

    @$meshCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasPixelSize = new ReactiveField null, EJSON.equals
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @meshId = new ComputedField =>
      @editorView.activeFileId()

    @meshLoader = new ComputedField =>
      return unless meshId = @meshId()
      @interface.getLoaderForFile meshId

    @meshData = new ComputedField =>
      @meshLoader()?.meshData()

    @mesh = new ComputedField =>
      @meshLoader()?.mesh

    @cameraAngle = new ComputedField =>
      @meshData()?.cameraAngles.get @cameraAngleIndex()

    @selection = new ComputedField =>
      @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.Selection

    @activeObjectIndex = new ComputedField =>
      @selection()?.objectIndex()

    @activeObject = new ComputedField =>
      @meshData()?.objects.get @activeObjectIndex()

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    @activeLayerIndex = new ComputedField =>
      @paintHelper.layerIndex()

    @activeLayer = new ComputedField =>
      @activeObject()?.layers.get @activeLayerIndex()
      
    @activePicture = new ComputedField =>
      @activeLayer()?.getPictureForCameraAngleIndex @cameraAngleIndex()

    @pixelRenderEnabled = new ComputedField =>
      @editorFileData()?.get('pixelRenderEnabled') ? true

    @debugMode = new ComputedField =>
      @interface.getOperator(LOI.Assets.MeshEditor.Actions.DebugMode).active()

    @pbrEnabled = new ComputedField =>
      @interface.getHelperForActiveFile(LOI.Assets.MeshEditor.Helpers.PBREnabled)?()

    @giEnabled = new ComputedField =>
      @interface.getHelperForActiveFile(LOI.Assets.MeshEditor.Helpers.GIEnabled)?()

    # Provide the fake sprite data object to sprite editor views.
    # Currently this is used only to draw tool previews correctly.
    @spriteData = new ComputedField =>
      return unless meshData = @meshData()

      # The sprite expects materials as a map instead of an array.
      materials = @meshData().materials.getAllAsIndexedMap()

      new LOI.Assets.Sprite
        palette: _.pick meshData.palette, ['_id']
        materials: materials

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'

    # Create the pixel canvas and its components.
    @edges = new @constructor.Edges @
    @edgePixels = new @constructor.EdgePixels @
    @horizon = new @constructor.Horizon @

    @pixelCanvas = new LOI.Assets.SpriteEditor.PixelCanvas
      spriteData: @spriteData
      fileIdForHelpers: @meshId
      landmarksHelperClass: LOI.Assets.MeshEditor.Helpers.Landmarks
      drawComponents: =>
        sourceImageEnabled = @sourceImageEnabled()

        # Some of the elements are derived from the first camera angle,
        # so we only draw them when looking from that camera angle.
        drawCameraAngleZeroElements = @cameraAngleIndex() is 0

        [
          @pixelCanvas.operationPreview()
          @pixelCanvas.pixelGrid()
          @edgePixels if drawCameraAngleZeroElements
          @edges if sourceImageEnabled and drawCameraAngleZeroElements
          @horizon if sourceImageEnabled
          @pixelCanvas.cursor()
          @pixelCanvas.landmarks() if sourceImageEnabled and drawCameraAngleZeroElements
          @pixelCanvas.toolInfo()
        ]

    # Provide the pixel canvas fields to sprite editor views and tools.
    for passThroughField in ['camera', 'mouse', 'cursor', 'pixelGridEnabled', 'landmarksEnabled', 'operationPreview', 'toolInfo']
      do (passThroughField) =>
        @[passThroughField] = => @pixelCanvas[passThroughField] arguments...

    @componentData = @interface.getComponentData @
    @componentFileData = new ComputedField =>
      @interface.getComponentDataForFile @, @meshId()

    # Prepare helpers.
    @drawComponents = new ComputedField =>
      return unless componentIds = @componentData.get 'components'

      for componentId in componentIds
        @interface.getHelperForFile componentId, @meshId()

    @sceneHelper = new ComputedField =>
      @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.Scene, @meshId()

    @characterPreviewHelper = new ComputedField =>
      @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.CharacterPreview, @meshId()

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
    
    @currentClusterHelper = new ComputedField =>
      @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.CurrentCluster, @meshId()

    # Initialize components.
    @planeGrid new @constructor.PlaneGrid @
    @debugRay new @constructor.DebugRay @

    @references new LOI.Assets.Editor.References.DisplayComponent
      assetId: @meshId
      documentClass: LOI.Assets.Mesh
      assetOptions: =>
        upload:
          enabled: false
        storage:
          enabled: false
      embeddedTransform: =>
        camera = @pixelCanvas.camera()

        origin: camera.origin()
        scale: camera.scale()

    # Register with the app to support updates.
    @app = @ancestorComponent Retronator.App
    @app.addComponent @

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $meshCanvas = @$('.landsofillusions-assets-mesheditor-meshcanvas')
    @$meshCanvas $meshCanvas

    canvas = $meshCanvas.find('.canvas')[0]
    @canvas canvas
    @context canvas.getContext 'webgl',
      alpha: true
      powerPreference: 'high-performance'

    @autorun (computation) =>
      # Depend on editor view size.
      AM.Window.clientBounds()

      # Depend on application area changes.
      @interface.currentApplicationAreaData().value()
      
      # Depend on editor view tab changes.
      @editorView.tabDataChanged.depend()

      # After update, measure the size.
      Tracker.afterFlush =>
        newSize =
          width: $meshCanvas.width()
          height: $meshCanvas.height()

        console.log "Updating canvas pixel size to", newSize if LOI.Assets.debug
          
        # Resize the back buffer to canvas element size, if it actually changed. If the pixel
        # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
        for key, value of newSize
          canvas[key] = value unless canvas[key] is value

        @canvasPixelSize newSize
          
    @renderer = new @constructor.Renderer @
    
  onDestroyed: ->
    super arguments...

    @renderer.destroy()

    @app.removeComponent @

  update: (appTime) ->
    return unless @isRendered()

    sceneHelper = @sceneHelper()
    scene = sceneHelper.scene()
    camera = @renderer.cameraManager.camera().main

    sceneUpdated = false

    for sceneItem in scene.children when sceneItem instanceof AS.RenderObject
      if sceneItem.update?
        sceneItem.update appTime, {camera}
        sceneUpdated = true

    sceneHelper.scene.updated() if sceneUpdated

  draw: (appTime) ->
    @renderer?.draw appTime

  draggingClass: ->
    'dragging' if _.some [
      @references().dragging()
    ]
