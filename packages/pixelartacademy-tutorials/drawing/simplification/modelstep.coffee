AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mummification
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Model = PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model

class PAA.Tutorials.Drawing.Simplification.ModelStep extends TutorialBitmap.PathStep
  # Override to select specific meshes from the model.
  @meshSelector: (mesh) -> true
  
  # Override to define the style of the generated paths.
  @style: (fill) -> "opacity:1;fill:#{if fill then '#000000' else 'none'};stroke:#000000;stroke-width:0.1;stroke-linecap:square;stroke-linejoin:bevel"

  constructor: ->
    super arguments...
    
    @_referenceUrl = new AE.LiveComputedField =>
      return unless stepAreaData = @stepArea.data()
      stepAreaData.referenceUrl
    
    @_startedDrawingAutorun = Tracker.autorun =>
      return unless @isActiveStepInArea()
      return unless referenceComponent = @referenceComponent()
      return unless referenceUrl = @_referenceUrl()
      
      # Only change input if we're at the end of the bitmap history (so we can undo/redo normally).
      bitmap = LOI.Assets.Bitmap.documents.findOne @tutorialBitmap.bitmapId()
      historyLength = AM.Document.Versioning.ActionArchive.getHistoryLengthForDocument bitmap._id
      return unless bitmap.historyPosition is historyLength
      
      return unless reference = _.find bitmap.references, (reference) => reference.image.url is referenceUrl
      
      bitmap.initialize()
      hasPixel = false
      
      for x in [@stepArea.bounds.x...@stepArea.bounds.x + @stepArea.bounds.width]
        for y in [@stepArea.bounds.y...@stepArea.bounds.y + @stepArea.bounds.height]
          if bitmap.findPixelAtAbsoluteCoordinates x, y
            hasPixel = true
            break
        break if hasPixel
        
      input = reference.displayOptions?.input ? true
      
      # If any pixels were drawn in this step's area, input should be disabled.
      if hasPixel and input
        referenceComponent.changeDisplayOptions input: false, true
        
      else unless hasPixel or input
        referenceComponent.changeDisplayOptions input: {}, true
  
  destroy: ->
    super arguments...
    
    @_referenceUrl.stop()
    @_startedDrawingAutorun.stop()
    @referenceComponent?.stop()

  solve: ->
    stepAreaData = @stepArea.data()
    referenceData = @tutorialBitmap.getReferenceDataForUrl stepAreaData.referenceUrl

    previewConfiguration =
      imageUrl: referenceData.image.url
      width: @stepArea.bounds.width
      height: @stepArea.bounds.height
      displayOptions: EJSON.clone(referenceData.displayOptions or {})

    aspectRatio = previewConfiguration.width / previewConfiguration.height
    camera = Model.Helpers.createCamera THREE, previewConfiguration.displayOptions.camera, aspectRatio
    previewRequestKey = Model.PreviewRenderer.getConfigurationKey previewConfiguration

    # Request the meshes directly since the reference component is not available when solving from the portfolio.
    await new Promise (resolve, reject) =>
      Model.PreviewRenderer.render previewConfiguration, (imageDataUrl, meshes) =>
        try
          svgPaths = @_createSvgPathsFromModel meshes, camera
          TutorialBitmap.PathStep::_initializePaths.call @, svgPaths
          resolve()

        catch error
          reject error

        finally
          Model.PreviewRenderer.release previewRequestKey

    super arguments...
  
  _initializePaths: (svgPaths) ->
    # Note: We need to create the fields here because initialize paths gets called from the parent constructor.
    Tracker.nonreactive =>
      @referenceComponent ?= new AE.LiveComputedField =>
        return unless @tutorialBitmap.isActiveDrawingInEditor()
        return unless stepAreaData = @stepArea.data()
        return unless drawingEditor = @getEditor()
        return unless referencesView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.References
        referencesView.displayComponent.getReferenceComponentForUrl stepAreaData.referenceUrl
      ,
        (a, b) => a is b
      
    return unless @tutorialBitmap.isActiveDrawingInEditor()
    return unless @isActiveStepInArea()
    
    # We need a model reference to read its camera and meshes.
    return unless referenceComponent = @referenceComponent()
    
    # See if we have a live camera.
    if cameraManager = referenceComponent.cameraManager()
      camera = cameraManager.camera.withUpdates()
    
    else
      # Fall back to a camera based on reference properties.
      return unless viewportSize = referenceComponent.viewportSize()
      return unless cameraData = referenceComponent.data().displayOptions?.camera
      return unless camera = Model.Helpers.createCamera THREE, cameraData, 1

      Model.Helpers.updateCameraAspectRatio camera, viewportSize.width / viewportSize.height
      Model.Helpers.applyCameraProperties camera, Model.Helpers.getCameraProperties cameraData

    # See if we have a live scene.
    if sceneManager = referenceComponent.sceneManager()
      # The scene manager is created before the model has loaded, so keep the previous paths until its scene is ready.
      return unless sceneManager.ready()

      scene = sceneManager.scene.withUpdates()

      # Find all mesh objects in the scene.
      meshes = []
      scene.traverse (object) =>
        return unless object.isMesh
        meshes.push object

    else
      # Fall back to static meshes from the preview.
      return unless meshes = referenceComponent.previewMeshes()

    svgPaths = @_createSvgPathsFromModel meshes, camera
    super svgPaths

  _createSvgPathsFromModel: (meshes, camera) ->
    meshes = _.filter meshes, (mesh) => @constructor.meshSelector mesh
  
    # Create SVG paths from the meshes.
    svgPaths = []
    
    for mesh in meshes
      unless mesh.triangulatedSurface
        # Prepare triangulated surface.
        mesh.uniqueVertexIndices = []
        mesh.triangulatedSurface = AP.TriangulatedSurface.fromBufferGeometry mesh.geometry,
          uniqueVertexIndices: mesh.uniqueVertexIndices
          
      if mesh.morphTargetInfluences?.length
        baseCoordinates = mesh.geometry.attributes.position.array
        targets = for weight, morphTargetIndex in mesh.morphTargetInfluences
          coordinates: mesh.geometry.morphAttributes.position[morphTargetIndex].array
          weight: weight
          
        mesh.triangulatedSurface.morphVertices baseCoordinates, targets, mesh.uniqueVertexIndices
      
      # Get its silhouette for the current camera and object transform.
      polygonalChains = mesh.triangulatedSurface.getSilhouette mesh.matrixWorld, camera
      
      svgPathDStrings = []
      
      for polygonalChain in polygonalChains when polygonalChain.isClosed()
        # Transform to step area space.
        for vertex in polygonalChain.vertices
          vertex.x = (vertex.x / 2 + 0.5) * @stepArea.bounds.width
          vertex.y = (-vertex.y / 2 + 0.5) * @stepArea.bounds.height
        
        svgPathDStrings.push polygonalChain.getSVGPathDString()
        
      continue unless svgPathDStrings.length
      
      pathElement = document.createElementNS 'http://www.w3.org/2000/svg', 'path'
      pathElement.setAttribute 'd', svgPathDStrings.join ' '
      pathElement.setAttribute 'style', @constructor.style @options.fill
      
      svgPaths.push pathElement

    svgPaths
