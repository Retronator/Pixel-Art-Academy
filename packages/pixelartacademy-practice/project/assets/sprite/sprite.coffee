AB = Artificial.Babel
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

  # Override to provide a string with more information related to the sprite (e.g. author info in challenges).
  @spriteInfo: -> null

  @initialize: ->
    super

    # On the server, create this assets's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()

        for property in ['spriteInfo']
          if value = @[property]?()
            AB.createTranslation translationNamespace, property, value

  constructor: ->
    super

    @spriteId = new ComputedField =>
      return unless assets = @project.assetsData()
      return unless asset = _.find assets, (asset) => asset.id is @id()

      asset.sprite._id
    ,
      true

    # Subscribe and find the sprite.
    @sprite = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId
    ,
      true

    @briefComponent = new @constructor.BriefComponent @

  destroy: ->
    super

    @spriteId.stop()
    @sprite.stop()

  width: -> @sprite()?.bounds.width
  height: -> @sprite()?.bounds.height

  fixedDimensions: -> @constructor.fixedDimensions()

  restrictedPalette: ->
    LOI.Assets.Palette.documents.findOne
      name: @constructor.restrictedPaletteName()

  spriteInfo: -> AB.translate(@_translationSubscription, 'spriteInfo').text
  spriteInfoTranslation: -> AB.translation @_translationSubscription, 'spriteInfo'
