FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshLoader extends FM.Loader
  constructor: ->
    super arguments...

    @_meshData = null
    @_meshDataDependency = new Tracker.Dependency

    @meshData = =>
      # React to changes from the server.
      @_meshDataDependency.depend()
      return unless @_meshData

      # React to local changes.
      @_meshData.depend()

      # Return the current object.
      @_meshData

    # Create the alias for universal operators.
    @asset = @meshData

    # Also listen to updates in non-managed fields.
    @_subscription = LOI.Assets.Asset.forIdFull.subscribe LOI.Assets.Mesh.className, @fileId

    @autorun (computation) =>
      return unless meshData = LOI.Assets.Mesh.documents.findOne @fileId
      
      if @_meshData
        # Overwrite plain properties of the singleton mesh data.
        for property in ['name', 'editor', 'palette', 'authors', 'references']
          if meshData[property]
            @_meshData[property] = meshData[property]
  
          else if @_meshData[property]
            delete @_meshData[property]
            
      else
        # Initialize the singleton mesh data.
        @_meshData = meshData
        @_meshData.initialize()

      # Signal change from server.
      @_meshDataDependency.changed()

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'
    @sceneHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.Scene, @fileId
    @debugModeData = @interface.getOperator(LOI.Assets.MeshEditor.Actions.DebugMode).data
    @currentClusterHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.CurrentCluster, @fileId

    # Create the engine mesh.
    @mesh = new LOI.Assets.Engine.Mesh
      meshData: @meshData
      visualizeNormals: @paintNormalsData.value
      sceneManager: => @sceneHelper
      debug: @debugModeData.value
      currentCluster: @currentClusterHelper.cluster

    # Subscribe to the referenced palette as well.
    @paletteId = new ComputedField =>
      @meshData()?.palette?._id

    @_paletteSubscription = Tracker.autorun (computation) =>
      return unless paletteId = @paletteId()
      LOI.Assets.Palette.forId.subscribe paletteId

    @palette = new ComputedField =>
      if paletteId = @paletteId()
        LOI.Assets.Palette.documents.findOne paletteId

      else
        # See if we have an embedded custom palette.
        @meshData()?.customPalette

  destroy: ->
    @_subscription.stop()
    @_spritesSubscription.stop()
    @_paletteSubscription.stop()

    @meshData.stop()
    @paletteId.stop()
    @palette.stop()
