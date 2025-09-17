AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_size = new THREE.Vector3

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.SceneManager
  @_textureCache = {}
  
  @fullMeshVisibilityAdjustmentDelta = 50 # display pixels
  
  constructor: (@reference) ->
    @_scene = new THREE.Scene()
    @_scene.manager = @
    @scene = new AE.ReactiveWrapper @_scene
    
    @_modelSceneDependency = new Tracker.Dependency
    
    @_meshVisibilityProperties = new ReactiveField
      amountVisible: 1
      sizePreference: 0
    
    @environmentTexture = new ReactiveField null

    # Minimize reactivity.
    @imageUrl = new AE.LiveComputedField => @reference.data()?.image.url
    @environment = new AE.LiveComputedField => @reference.data()?.displayOptions?.environment
    @background = new AE.LiveComputedField => @reference.data()?.displayOptions?.background
    
    # Update scene based on the reference url.
    @reference.autorun =>
      return unless imageUrl = @imageUrl()
      
      PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.Loader.load imageUrl, (data) =>
        @_scene.remove @_modelScene if @_modelScene
        
        @_modelScene = data.scene
        @_scene.add @_modelScene
        
        @scene.updated()
        @_modelSceneDependency.changed()
        
    # Update mesh visibility properties from the reference.
    @reference.autorun =>
      return unless meshVisibility = @reference.data().displayOptions?.meshVisibility
      
      properties = Tracker.nonreactive => @_meshVisibilityProperties()
      properties.amountVisible = meshVisibility.amountVisible ? 1
      properties.sizePreference = meshVisibility.sizePreference ? 0
      @_meshVisibilityProperties properties
      
    # Update mesh visibility.
    @reference.autorun =>
      @_modelSceneDependency.depend()
      meshVisibilityProperties = @_meshVisibilityProperties()
      
      # Collect all the meshes.
      orderedMeshes = []
      
      @_scene.traverse (object) =>
        return unless object.isMesh
        
        #object.geometry.computeBoundingSphere()
        object.geometry.computeBoundingBox()
        object.geometry.boundingBox.getSize _size
        
        orderedMeshes.push
          mesh: object
          #size: object.geometry.boundingSphere.radius
          size: _size.x * _size.y * _size.z
          priorityOrder: orderedMeshes.length + 1
      
      orderedMeshes.sort (a, b) => b.size - a.size
        
      sizeWeight = meshVisibilityProperties.sizePreference
      priorityWeight = 1 - sizeWeight
      
      for orderedMesh, meshIndex in orderedMeshes
        orderedMesh.sizeOrder = meshIndex + 1
        orderedMesh.weightedOrder = orderedMesh.priorityOrder * priorityWeight + orderedMesh.sizeOrder * sizeWeight
        
      orderedMeshes.sort (a, b) =>  a.weightedOrder - b.weightedOrder
      
      visibleCount = 1 + (orderedMeshes.length - 1) * meshVisibilityProperties.amountVisible

      for orderedMesh, meshIndex in orderedMeshes
        orderedMesh.mesh.visible = meshIndex < visibleCount
      
      @scene.updated()
        
    # Update environment.
    @reference.autorun =>
      return unless environmentUrl = @environment()?.url

      if cachedTexture = @constructor._textureCache[environmentUrl]
        @environmentTexture cachedTexture
        return
      
      new THREE.HDRLoader().load environmentUrl, (texture) =>
        @_environmentTexture?.dispose()
        
        @_environmentTexture = texture
        @_environmentTexture.mapping = THREE.EquirectangularReflectionMapping
        @_environmentTexture.magFilter = THREE.LinearFilter
        
        @constructor._textureCache[environmentUrl] = @_environmentTexture
        @environmentTexture @_environmentTexture
      
    @reference.autorun =>
      @_scene.environment = @environmentTexture()
      @scene.updated()
    
    @reference.autorun =>
      return unless environmentRotation = @environment()?.rotation
      @_scene.environmentRotation.set(
        environmentRotation.x or 0
        environmentRotation.y or 0
        environmentRotation.z or 0
        environmentRotation.order
      )
      @scene.updated()
      
    # Update background.
    @reference.autorun =>
      return unless background = @background()
      
      if background.color
        @_scene.background = new THREE.Color background.color
        
      else if background.environment
        @_scene.background = @environmentTexture()
        
      @scene.updated()
  
  destroy: ->
    @imageUrl.stop()
    @environment.stop()
    @background.stop()
  
  startAdjustMeshVisibility: (event) ->
    startClientCoordinatesX = event.clientX
    startClientCoordinatesY = event.clientY
    
    startProperties = _.clone @_meshVisibilityProperties()
    
    # Wire movement of the mouse anywhere in the window.
    $(document).on 'pointermove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', (event) =>
      scale = @reference.display.scale()
      
      dragDeltaX = (event.clientX - startClientCoordinatesX) / scale / @constructor.fullMeshVisibilityAdjustmentDelta
      dragDeltaY = (event.clientY - startClientCoordinatesY) / scale / @constructor.fullMeshVisibilityAdjustmentDelta

      # Only react to mouse coordinate changes.
      properties = @_meshVisibilityProperties()
      
      properties.amountVisible = _.clamp startProperties.amountVisible + dragDeltaX, 0, 1
      properties.sizePreference = _.clamp startProperties.sizePreference + dragDeltaY, 0, 1
      
      @_meshVisibilityProperties properties

    # Wire end of dragging on pointer up anywhere in the window.
    $(document).on 'pointerup.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', =>
      $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager'
      
      properties = @_meshVisibilityProperties()
      
      @reference.changeDisplayOptions
        meshVisibility: properties
