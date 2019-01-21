FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshLoader extends FM.Loader
  constructor: ->
    super arguments...
    
    @_subscription = LOI.Assets.Asset.forId.subscribe LOI.Assets.Mesh.className, @fileId
    @_spritesSubscription = LOI.Assets.Sprite.forMeshId.subscribe @fileId

    @meshData = new ComputedField =>
      return unless mesh = LOI.Assets.Mesh.documents.findOne @fileId

      # Refresh to embed sprite documents.
      mesh.refresh()

      mesh

    # Create the alias for universal operators.
    @asset = @meshData

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
