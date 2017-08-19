AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk extends LOI.Character.Part
  @Keys: {}

  @create: (options) ->
    if Meteor.isServer
      @_createTranslation options.key, 'name', options.name
      @_createTranslation options.key, 'description', options.description
      @_createTranslation options.key, 'effects', options.effects
      @_createTranslation options.key, 'requirements', options.requirements

    @Keys[options.key] = options.key

  # Inserts an item for an inherited item with metadata set on the class.
  @createSelf: ->
    @create
      key: @key
      # We can't use name on the class, so we need to pass display name instead.
      name: @displayName
      effects: @effects
      requirements: @requirements

  @_createTranslation: (perkKey, translationKey, defaultText) ->
    namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
    AB.createTranslation namespace, translationKey, defaultText

  @satisfiesRequirements: (behaviorPart) ->
    # Override this with custom logic that tests whether the character can have this perk.

  satisfiesRequirements: ->
    console.log "test", @
