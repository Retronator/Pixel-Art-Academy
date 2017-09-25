AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk extends LOI.Character.Part
  @Keys: {}
  
  # Minimum factor power for perks based on personality factors.
  @factorPowerCutoff: 8
  
  @register: (@key) ->
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        @_createTranslation @key, 'name', @displayName
        @_createTranslation @key, 'description', @description
        @_createTranslation @key, 'effects', @effects
        @_createTranslation @key, 'requirements', @requirements

    @Keys[@key] = @key

    LOI.Character.Part.registerClasses
      Behavior:
        Perk:
          "#{@key}": new @
            type: "Behavior.Perk.#{@key}"
            properties:
              key: new LOI.Character.Part.Property.String

  @_createTranslation: (perkKey, translationKey, defaultText) ->
    namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
    AB.createTranslation namespace, translationKey, defaultText

  @satisfiesRequirements: (behaviorPart) ->
    # Override this with custom logic that tests whether the character can have this perk.
