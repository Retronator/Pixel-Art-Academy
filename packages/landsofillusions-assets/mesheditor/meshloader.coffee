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

    @displayName = new ComputedField =>
      return unless meshData = @meshData()
      meshData.name or meshData._id

    # Load the full document from the server. Note: we can't get this with a subscription
    # because we're already subscribed to the name-only version of the meshes.
    LOI.Assets.Mesh.load @fileId, (error, meshData) =>
      if error
        console.error error
        return

      # Initialize the singleton mesh data.
      @_meshData = new LOI.Assets.Mesh meshData
      @_meshData.initialize true, @_meshDataDependency
      object.solver.initialize() for object in @_meshData.objects.getAll()

      # Signal initial change.
      @_meshDataDependency.changed()

    # Also listen to updates in non-managed fields.
    @_subscription = LOI.Assets.Asset.forId.subscribe LOI.Assets.Mesh.className, @fileId

    @autorun (computation) =>
      return unless meshData = LOI.Assets.Mesh.documents.findOne @fileId
      return unless @_meshData

      # Overwrite plain properties of the singleton mesh data.
      for property in ['name', 'editor', 'palette', 'authors', 'planeGrid', 'references', 'environments']
        if meshData[property]
          @_meshData[property] = meshData[property]

        else if @_meshData[property]
          delete @_meshData[property]

      # Signal change from server.
      @_meshDataDependency.changed()

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'
    @sceneHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.Scene, @fileId
    @debugModeData = @interface.getOperator(LOI.Assets.MeshEditor.Actions.DebugMode).data
    @currentClusterHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.CurrentCluster, @fileId
    @colorQuantizationHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.ColorQuantizationEnabled, @fileId
    @pbrHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.PBREnabled, @fileId
    @giHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.GIEnabled, @fileId

    # Create the engine mesh.
    @mesh = new LOI.Assets.Engine.Mesh
      meshData: @meshData
      visualizeNormals: @paintNormalsData.value
      sceneManager: @sceneHelper
      debug: @debugModeData.value
      currentCluster: @currentClusterHelper.cluster
      colorQuantization: @colorQuantizationHelper
      pbr: @pbrHelper
      gi: @giHelper

    # Add mesh to the scene.
    @sceneHelper.scene().add @mesh
    @sceneHelper.addedSceneObjects()

    # Subscribe to the referenced palette.
    @paletteId = new ComputedField =>
      @meshData()?.palette?._id

    @_paletteSubscriptionAutorun = Tracker.autorun (computation) =>
      return unless paletteId = @paletteId()
      LOI.Assets.Palette.forId.subscribe paletteId

    @palette = new ComputedField =>
      if paletteId = @paletteId()
        LOI.Assets.Palette.documents.findOne paletteId

      else
        # See if we have an embedded custom palette.
        @meshData()?.customPalette

    # Subscribe to texture sprites.
    @_textureSpritesSubscriptionAutorun = Tracker.autorun (computation) =>
      return unless meshData = @meshData()

      # Note that we can't use Sprite.forMeshId subscription here since
      # we want to subscribe to the live (unsaved) mesh material data.
      for material in meshData.materials.getAll() when material.texture
        if material.texture.spriteId
          LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, material.texture.spriteId

        else if material.texture.spriteName
          LOI.Assets.Asset.forPath.subscribe LOI.Assets.Sprite.className, material.texture.spriteName

    @_pictureThumbnails = []

  destroy: ->
    @_subscription.stop()
    @_paletteSubscriptionAutorun.stop()
    @_textureSpritesSubscriptionAutorun.stop()

    @paletteId.stop()
    @palette.stop()

    @_meshData.destroy()
    @mesh.destroy()

  getPictureThumbnail: (picture) ->
    pictureThumbnail = _.find @_pictureThumbnails, (pictureThumbnail) => pictureThumbnail.picture is picture

    unless pictureThumbnail
      Tracker.nonreactive =>
        thumbnail = new LOI.Assets.MeshEditor.Thumbnail.Picture picture

        update = _.debounce =>
          thumbnail.update()
        ,
          1000

        @autorun =>
          picture.depend()
          update()

        pictureThumbnail = {picture, thumbnail}
        @_pictureThumbnails.push pictureThumbnail

    # Return the thumbnail itself.
    pictureThumbnail.thumbnail
