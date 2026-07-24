AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Model = PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model

class Model.SceneManager
  @_textureCache = {}
  
  @fullMeshVisibilityAdjustmentDelta = 50 # display pixels
  @fullMeshMorphingAdjustmentDelta = 50 # display pixels
  
  constructor: (@reference) ->
    @_scene = new THREE.Scene()
    @_scene.manager = @
    @scene = new AE.ReactiveWrapper @_scene
    @ready = new ReactiveField false
    
    @_modelSceneDependency = new Tracker.Dependency
    
    @meshVisibilityProperties = new ReactiveField
      amountVisible: 1
      sizePreference: 0
    
    @meshMorphingProperties = new ReactiveField {}
    
    @environmentTexture = new ReactiveField null

    # Minimize reactivity.
    @imageUrl = new AE.LiveComputedField => @reference.data()?.image.url
    @environment = new AE.LiveComputedField (=> @reference.data()?.displayOptions?.environment), EJSON.equals
    @background = new AE.LiveComputedField (=> @reference.data()?.displayOptions?.background), EJSON.equals
    @meshVisibility = new AE.LiveComputedField (=> @reference.data()?.displayOptions?.meshVisibility), EJSON.equals
    
    # Update scene based on the reference url.
    @reference.autorun =>
      return unless imageUrl = @imageUrl()
      
      Model.Loader.load imageUrl, (data) =>
        @_scene.remove @_modelScene if @_modelScene
        
        @_modelScene = data.scene
        @_scene.add @_modelScene
        
        @scene.updated()
        @_modelSceneDependency.changed()
        @ready true
        
    # Update mesh visibility properties from the reference.
    @reference.autorun =>
      return unless meshVisibility = @meshVisibility()
      
      @meshVisibilityProperties Model.Helpers.getMeshVisibilityProperties meshVisibility
      
    # Update mesh visibility.
    @reference.autorun =>
      return unless meshVisibility = @meshVisibility()
      
      @_modelSceneDependency.depend()
      meshVisibilityProperties = @meshVisibilityProperties()
      
      Model.Helpers.applyMeshVisibility THREE, @_scene, meshVisibility, meshVisibilityProperties
      @scene.updated()
      
    # Update mesh morphing properties from the reference.
    @reference.autorun =>
      return unless meshMorphing = @reference.data().displayOptions?.meshMorphing
      
      properties = Tracker.nonreactive => @meshMorphingProperties()
      _.extend properties, meshMorphing
      @meshMorphingProperties properties
    
    # Update mesh morphing.
    @reference.autorun =>
      @_modelSceneDependency.depend()
      meshMorphingProperties = @meshMorphingProperties()
      
      Model.Helpers.applyMeshMorphing @_scene, meshMorphingProperties
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
        Model.Helpers.configureEnvironmentTexture THREE, @_environmentTexture
        
        @constructor._textureCache[environmentUrl] = @_environmentTexture
        @environmentTexture @_environmentTexture
      
    @reference.autorun =>
      Model.Helpers.applyEnvironment @_scene, @environmentTexture(), @environment()
      @scene.updated()
      
    # Update background.
    @reference.autorun =>
      return unless background = @background()
      
      Model.Helpers.applyBackground THREE, @_scene, @environmentTexture(), background
      @scene.updated()
  
  destroy: ->
    @imageUrl.stop()
    @environment.stop()
    @background.stop()
    @meshVisibility.stop()
  
  startAdjustMeshVisibility: (event) ->
    startClientCoordinatesX = event.clientX
    startClientCoordinatesY = event.clientY
    
    startProperties = _.clone @meshVisibilityProperties()
    
    # Wire movement of the mouse anywhere in the window.
    $(document).on 'pointermove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', (event) =>
      scale = @reference.display.scale()
      
      dragDeltaX = (event.clientX - startClientCoordinatesX) / scale / @constructor.fullMeshVisibilityAdjustmentDelta
      dragDeltaY = (event.clientY - startClientCoordinatesY) / scale / @constructor.fullMeshVisibilityAdjustmentDelta

      # Only react to mouse coordinate changes.
      properties = @meshVisibilityProperties()
      
      properties.amountVisible = _.clamp startProperties.amountVisible + dragDeltaX, 0, 1
      properties.sizePreference = _.clamp startProperties.sizePreference + dragDeltaY, 0, 1
      
      @meshVisibilityProperties properties

    # Wire end of dragging on pointer up anywhere in the window.
    $(document).on 'pointerup.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', =>
      $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager'
      
      properties = @meshVisibilityProperties()
      
      @reference.changeDisplayOptions
        meshVisibility: properties

  startAdjustMeshMorphing: (event, morphAxes) ->
    startClientCoordinatesX = event.clientX
    startClientCoordinatesY = event.clientY
    
    startProperties = _.clone @meshMorphingProperties()
    startProperties[morphKey] ?= 0 for axis, morphKey of morphAxes
    
    # Wire movement of the mouse anywhere in the window.
    $(document).on 'pointermove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', (event) =>
      scale = @reference.display.scale()
      
      # Only react to mouse coordinate changes.
      properties = @meshMorphingProperties()
      
      if morphAxes.horizontal
        dragDeltaX = (event.clientX - startClientCoordinatesX) / scale / @constructor.fullMeshMorphingAdjustmentDelta
        properties[morphAxes.horizontal] = _.clamp startProperties[morphAxes.horizontal] + dragDeltaX, 0, 1
      
      if morphAxes.vertical
        dragDeltaY = (event.clientY - startClientCoordinatesY) / scale / @constructor.fullMeshMorphingAdjustmentDelta
        properties[morphAxes.vertical] = _.clamp startProperties[morphAxes.vertical] + dragDeltaY, 0, 1
      
      @meshMorphingProperties properties

    # Wire end of dragging on pointer up anywhere in the window.
    $(document).on 'pointerup.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', =>
      $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager'
      
      properties = @meshMorphingProperties()
      
      @reference.changeDisplayOptions
        meshMorphing: properties
