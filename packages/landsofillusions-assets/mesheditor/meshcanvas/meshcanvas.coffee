AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
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
    horizonEnabled: false
    pixelRenderEnabled: true
    planeGridEnabled: true
    sourceImageEnabled: false

  constructor: ->
    super arguments...

    @planeGrid = new ReactiveField null

    @$meshCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasPixelSize = new ReactiveField null
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @meshId = new ComputedField =>
      @editorView.activeFileId()

    @meshLoader = new ComputedField =>
      return unless meshId = @meshId()
      @interface.getLoaderForFile meshId

    @mesh = new ComputedField =>
      @meshLoader().mesh

    @cameraAngle = new ComputedField =>
      @meshLoader()?.meshData()?.cameraAngles?[@cameraAngleIndex()]

    @pixelRenderEnabled = new ComputedField =>
      @editorFileData()?.get('pixelRenderEnabled') ? true

    @debugMode = new ComputedField =>
      @interface.getOperator(LOI.Assets.MeshEditor.Actions.DebugMode).active()

    # Provide the sprite we're currently editing to sprite editor views.
    @spriteData = new ComputedField =>
      @cameraAngle()?.sprite

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'

    # Create the engine sprite.
    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormalsData.value

    @edges = new @constructor.Edges @
    @horizon = new @constructor.Horizon @

    @pixelCanvas = new LOI.Assets.SpriteEditor.PixelCanvas
      sprite: => @sprite
      fileIdForHelpers: @meshId
      drawComponents: =>
        sourceImageEnabled = @sourceImageEnabled()

        [
          @sprite if sourceImageEnabled
          @pixelCanvas.operationPreview()
          @pixelCanvas.pixelGrid()
          @edges if sourceImageEnabled
          @horizon
          @pixelCanvas.cursor()
          @pixelCanvas.landmarks() if sourceImageEnabled
        ]

    # Provide the pixel canvas fields to sprite editor views and tools.
    for passThroughField in ['camera', 'mouse', 'pixelGridEnabled', 'landmarksEnabled', 'operationPreview']
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

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
    
    @currentClusterHelper = new ComputedField =>
      @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.CurrentCluster, @meshId()

    # Initialize components.
    @planeGrid new @constructor.PlaneGrid @

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $meshCanvas = @$('.landsofillusions-assets-mesheditor-meshcanvas')
    @$meshCanvas $meshCanvas

    canvas = $meshCanvas.find('.canvas')[0]
    @canvas canvas
    @context canvas.getContext 'webgl'

    @autorun (computation) =>
      # Depend on editor view size.
      AM.Window.clientBounds()

      # Depend on application area changes.
      @interface.currentApplicationAreaData().value()

      # After update, measure the size.
      Tracker.afterFlush =>
        newSize =
          width: $meshCanvas.width()
          height: $meshCanvas.height()
          
        # Resize the back buffer to canvas element size, if it actually changed. If the pixel
        # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
        for key, value of newSize
          canvas[key] = value unless canvas[key] is value

        @canvasPixelSize newSize
          
    @renderer = new @constructor.Renderer @
    
  onDestroyed: ->
    super arguments...

    @renderer.destroy()
