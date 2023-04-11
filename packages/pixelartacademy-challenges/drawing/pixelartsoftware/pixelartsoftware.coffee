LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtSoftware extends LOI.Adventure.Thing
  # assets: array of assets that the player has chosen to complete for the Copy reference challenge
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #   completed: auto-updated field if the player completed this asset
  #   uploaded: tells if the player used the upload action for this asset
  #
  #   BITMAP
  #   bitmap: reference to a bitmap
  #     _id
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtSoftware'

  @fullName: -> "Pixel art software"

  @initialize()

  @translations: ->
    noAssetsInstructions: """
      To make sure you are ready to complete pixel art drawing assignments, this challenge requires you to copy an
      existing game bitmap in your editor of choice. First go to the Retronator HQ Gallery and talk to Corinne to
      obtain a reference image and further instructions.
    """

  constructor: ->
    super arguments...
    
    # Listen to asset completed changes to determine if editor and upload options are granted.
    @_assetsCompletedAutorun = Tracker.autorun =>
      canEdit = false
      canUpload = false

      if pixelArtSoftwareAssets = @state 'assets'
        for asset in pixelArtSoftwareAssets
          if asset.completed
            if asset.uploaded
              canUpload = true

            else
              canEdit = true

      Tracker.nonreactive =>
        Bitmap = PAA.Practice.Project.Asset.Bitmap

        Bitmap.state 'canEdit', canEdit unless canEdit is Bitmap.state 'canEdit'
        Bitmap.state 'canUpload', canUpload unless canUpload is Bitmap.state 'canUpload'

  destroy: ->
    @_assetsCompletedAutorun.stop()
    asset.destroy() for asset in @_pixelArtSoftwareAssets if @_pixelArtSoftwareAssets

  noAssetsInstructions: ->
    @translations()?.noAssetsInstructions

  assetsData: ->
    return unless LOI.adventure.readOnlyGameState()

    # We need to mimic a project, so we need to provide the data. If no state is
    # set, we send a dummy object to let the bitmap know we've loaded the state.
    @readOnlyState('assets') or []

  assets: ->
    assets = []

    @_pixelArtSoftwareAssets ?= []

    if pixelArtSoftwareAssets = @state 'assets'
      for asset in pixelArtSoftwareAssets
        assetClassName = _.last asset.id.split '.'
        @_pixelArtSoftwareAssets[asset.id] ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtSoftware.CopyReference[assetClassName] @

        assets.push @_pixelArtSoftwareAssets[asset.id]

    assets
