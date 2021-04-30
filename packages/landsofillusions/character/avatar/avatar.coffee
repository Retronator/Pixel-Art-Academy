AM = Artificial.Mummification
AB = Artificial.Babel
LOI = LandsOfIllusions

# Character's implementation of the avatar that takes the data from the character document.
class LOI.Character.Avatar extends LOI.HumanAvatar
  @id: -> 'LOI.Character.Avatar'

  constructor: (characterInstanceOrDocument) ->
    console.log "Creating character avatar", characterInstanceOrDocument if LOI.debug

    # We allow the avatar to be constructed for the character instance or directly for the document.
    if characterInstanceOrDocument instanceof LOI.Character.Instance
      document = => characterInstanceOrDocument.document avatar: true

    else
      document = => characterInstanceOrDocument

    # Create the body and outfit data hierarchies first.
    bodyDataField = AM.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      # TODO: We need to set the type somehow different so it's dynamic in the location (test with create template).
      type: LOI.Character.Part.Types.Avatar.Body.options.type
      load: new ComputedField =>
        document()?.avatar?.body
      ,
        EJSON.equals

      save: (address, value) =>
        LOI.Character.updateAvatarBody document()._id, address, value

    # Allow to supply a different outfit than the default one stored on the avatar.
    customOutfit = new ReactiveField null

    outfitDataField = AM.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      type: LOI.Character.Part.Types.Avatar.Outfit.options.type
      load: new ComputedField =>
        # Custom outfit has priority.
        data = customOutfit()
        return data if data

        # Avatar outfit is tried next.
        avatar = document()?.avatar
        data = avatar?.outfit
        return data if data

        # If we still have no outfit data, we allow the character to appear naked (for example in character creation).
        # In that case we send an a dummy node out to discern from the state where we're still loading the data.
        return unless avatar

        node: fields: {}
      ,
        EJSON.equals

      save: (address, value) =>
        LOI.Character.updateAvatarOutfit document()._id, address, value

    textures = new ComputedField =>
      if customOutfit() then null else document()?.avatar?.textures
    ,
      EJSON.equals

    # Now we can call HumanAvatar's constructor which will turn this data into an actual part hierarchy.
    super {bodyDataField, outfitDataField, textures}

    @document = document
    @customOutfit = customOutfit

  _avatar: ->
    @document()?.avatar

  characterId: ->
    @document()._id

  fullName: ->
    # We only want to return the loading text the document hasn't loaded yet. When
    # it has loaded, avatar could be null, in which case we need to return no-name.
    return @_loading() unless document = @document()

    document.avatar?.fullName?.translate().text or @_noName()

  shortName: ->
    # We only want to return the loading text the document hasn't loaded yet. When
    # it has loaded, avatar could be null, in which case we need to return no-name.
    return @_loading() unless document = @document()

    document.avatar?.shortName?.translate().text or @fullName()

  nameNounType: -> LOI.Avatar.NameNounType.Proper

  pronouns: ->
    @_avatar()?.pronouns or super arguments...

  _loading: ->
    return if Meteor.isServer

    AB.translate(@constructor._babelSubscription, 'Loading …').text

  _noName: ->
    return if Meteor.isServer

    @constructor.noName()

  color: ->
    return super(arguments...) unless color = @_avatar()?.color

    hue: color?.hue or LOI.Assets.Palette.Atari2600.hues.gray
    shade: color?.shade or LOI.Assets.Palette.Atari2600.characterShades.normal

  @noNameTranslationKey = 'NoName'

  @noNameTranslation: ->
    AB.translation @_babelSubscription, @noNameTranslationKey

  @noName: ->
    @noNameTranslation()?.translate().text

if Meteor.isClient
  # Subscribe to the avatar namespace in all languages, so that we can show all translations of "No Name" in the
  # dialogs. We do this because of a limitation in Meteor, where we can't later on request to get all translations
  # (top field), if we subscribed just to some translations (subfields) earlier.
  LOI.Character.Avatar._babelSubscription = AB.subscribeNamespace LOI.Character.Avatar.id(),
    # Null subscribes to all languages.
    languages: null

if Meteor.isServer
  AB.createTranslation LOI.Character.Avatar.id(), LOI.Character.Avatar.noNameTranslationKey, 'No Name'
