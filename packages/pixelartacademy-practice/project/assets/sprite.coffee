PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Sprite extends PAA.Practice.Project.Asset
  # Type of this asset.
  @type: -> @Types.Sprite

  # Override to provide an object with width and height to specify that this sprite has predefined dimensions.
  @fixedDimensions: -> null

  # Override to provide an object with width and height to specify that this sprite has a minimum size.
  @minDimensions: -> null

  # Override to provide an object with width and height to specify that this sprite has a maximum size.
  @maxDimensions: -> null

  # Override to provide the name of the palette this sprite must be created with.
  @restrictedPaletteName: -> null

  # Override to restrict the total number of colors used.
  @maxColorCount: -> null

  constructor: ->
    super

    @spriteId = new ComputedField =>
      return unless assets = @project.data()?.assets
      return unless asset = _.find assets, (asset) => asset.id is @id()

      asset.sprite._id

    # Subscribe and find the sprite.
    @sprite = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

  destroy: ->
    super

    @spriteId.stop()
    @sprite.stop()

  width: -> @sprite()?.bounds.width
  height: -> @sprite()?.bounds.height
