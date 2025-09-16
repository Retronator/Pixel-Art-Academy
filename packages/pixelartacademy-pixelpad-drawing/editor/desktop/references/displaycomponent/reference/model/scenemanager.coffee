AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.SceneManager
  @_textureCache = {}
  
  constructor: (@reference) ->
    @_scene = new THREE.Scene()
    @_scene.manager = @
    @scene = new AE.ReactiveWrapper @_scene
    
    @environmentTexture = new ReactiveField null

    # Minimize reactivity.
    @imageUrl = new AE.LiveComputedField => @reference.data()?.image.url
    @environmentUrl = new AE.LiveComputedField => @reference.data()?.displayOptions?.environment?.url
    @background = new AE.LiveComputedField => @reference.data()?.displayOptions?.background
    
    # Update scene based on the reference url.
    @reference.autorun =>
      return unless imageUrl = @imageUrl()
      
      PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.Loader.load imageUrl, (data) =>
        @_scene.remove @_modelScene if @_modelScene
        
        @_modelScene = data.scene
        @_scene.add @_modelScene
        
        @scene.updated()
        
    # Update environment.
    @reference.autorun =>
      return unless environmentUrl = @environmentUrl()

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
    @environmentUrl.stop()
