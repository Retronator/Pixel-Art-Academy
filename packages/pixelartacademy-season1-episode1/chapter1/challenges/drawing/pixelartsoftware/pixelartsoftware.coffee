LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware extends LOI.Adventure.Thing
  # assets: array of assets that the player has received from Corinne
  #   id: unique asset identifier
  #   completed: auto-updated field if the player completed this asset
  #   completionType: the way the player completed this asset
  #
  # READONLY
  # assets: array of assets that are part of this challenge
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #
  #   SPRITE
  #   sprite: reference to a sprite
  #     _id
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware'

  @fullName: -> "Pixel art software"

  @initialize()

  @translations: ->
    noAssetsInstructions: """
      To make sure you are ready to complete pixel art drawing assignments, this challenge requires you to copy an
      existing game sprite in your editor of choice. First go to the Retronator HQ Gallery and talk to Corinne to
      obtain a reference image and further instructions.
    """

  @CompletionType:
    Editor: 'Editor'
    Upload: 'Upload'

  constructor: ->
    super
    
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
        Sprite = PAA.Practice.Project.Asset.Sprite

        Sprite.state 'canEdit', canEdit unless canEdit is Sprite.state 'canEdit'
        Sprite.state 'canUpload', canUpload unless canUpload is Sprite.state 'canUpload'

  destroy: ->
    @_assetsCompletedAutorun.stop()
    asset.destroy() for asset in @_pixelArtSoftwareAssets

  noAssetsInstructions: ->
    @translations().noAssetsInstructions

  assetsData: ->
    return unless LOI.adventure.readOnlyGameState()

    # We need to mimic a project, so we need to provide the data. If no state is 
    # set, we send a dummy object to let the sprite know we've loaded the state.
    @readOnlyState('assets') or []

  assets: ->
    assets = []

    @_pixelArtSoftwareAssets ?= []

    if pixelArtSoftwareAssets = @state 'assets'
      for asset in pixelArtSoftwareAssets
        assetClassName = _.last asset.id.split '.'
        @_pixelArtSoftwareAssets[asset.id] ?= new C1.Challenges.Drawing.PixelArtSoftware.CopyReference[assetClassName] @

        assets.push @_pixelArtSoftwareAssets[asset.id]

    assets
