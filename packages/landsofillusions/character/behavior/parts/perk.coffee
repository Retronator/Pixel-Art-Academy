AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk extends LOI.Character.Part
  @Keys: {}

  @register: (@key) ->
    if Meteor.isServer
      Document.startup =>
        @_createTranslation @key, 'name', @displayName
        @_createTranslation @key, 'description', @description
        @_createTranslation @key, 'effects', @effects
        @_createTranslation @key, 'requirements', @requirements

    @Keys[@key] = @key

  @_createTranslation: (perkKey, translationKey, defaultText) ->
    namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
    AB.createTranslation namespace, translationKey, defaultText

  @satisfiesRequirements: (behaviorPart) ->
    # Override this with custom logic that tests whether the character can have this perk.

  satisfiesRequirements: ->
    console.log "test", @
