AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk extends LOI.Character.Part
  @create: (options) ->
    # Transform name and descriptions into translation documents.
    options.name =
      _id: @_createTranslation options.key, 'name', options.name

    options.description =
      _id: @_createTranslation options.key, 'description', options.description

    options.requirements =
      _id: @_createTranslation options.key, 'requirements', options.requirements

  # Inserts an item for an inherited item with metadata set on the class.
  @createSelf: ->
    @create @

  @_createTranslation: (perkKey, translationKey, defaultText) ->
    namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
    AB.createTranslation namespace, translationKey, defaultText

  constructor: (@options) ->

  satisfiesRequirements: ->
    # Override this with custom logic that tests whether the character can have this perk.
