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

  # Override to set which background color is used.
  @backgroundColor: -> null

  # Override to restrict the total number of colors used.
  @maxColorCount: -> null

  # Override to provide a string with more information related to the sprite (e.g. author info in challenges).
  @spriteInfo: -> null

  @briefComponentClass: ->
    # Override to provide a different brief component.
    @BriefComponent

  @initialize: ->
    super arguments...

    # On the server, create this assets's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()

        for property in ['spriteInfo']
          if value = @[property]?()
            AB.createTranslation translationNamespace, property, value

  constructor: ->
    super arguments...

    @spriteId = new ComputedField =>
      @data()?.sprite._id
    ,
      true

    # Subscribe and find the sprite.
    @sprite = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, spriteId
      LOI.Assets.Sprite.documents.findOne spriteId
    ,
      true

    briefComponentClass = @constructor.briefComponentClass()
    @briefComponent = new briefComponentClass @

  destroy: ->
    super arguments...

    @spriteId.stop()
    @sprite.stop()

  width: -> @sprite()?.bounds.width
  height: -> @sprite()?.bounds.height

  fixedDimensions: -> @constructor.fixedDimensions()

  restrictedPalette: ->
    return unless restrictedPaletteName = @constructor.restrictedPaletteName()

    LOI.Assets.Palette.documents.findOne
      name: restrictedPaletteName
      
  customPalette: ->
    @sprite()?.customPalette

  backgroundColor: ->
    return unless backgroundColor = @constructor.backgroundColor()

    if paletteColor = backgroundColor.paletteColor
      return unless palette = @restrictedPalette()
      palette.color paletteColor.ramp, paletteColor.shade

    else
      # We assume the color is already a color instance.
      backgroundColor

  spriteInfo: ->
    translation = AB.translate @_translationSubscription, 'spriteInfo'
    if translation.language then translation.text else null

  spriteInfoTranslation: -> AB.translation @_translationSubscription, 'spriteInfo'
    
  imageUrl: ->
    return unless spriteId = @spriteId()
    "/assets/sprite.png?spriteId=#{spriteId}"

# We want a generic state for sprite assets so we create it outside of the constructor as inherited classes don't need it. 
# canEdit: can the user edit the sprites with built-in editors
# canUpload: can the user upload sprites
Sprite = PAA.Practice.Project.Asset.Sprite

Sprite.stateAddress = new LOI.StateAddress "things.PixelArtAcademy.Practice.Project.Asset.Sprite"
Sprite.state = new LOI.StateObject address: Sprite.stateAddress
