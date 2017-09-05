AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Behavior.Perks extends LOI.Character.Part.Property.Array
  activePerks: ->
    behaviorPart = @options.parent

    _.filter @parts(), (part) => part.constructor.satisfiesRequirements behaviorPart

  toString: ->
    perks = @activePerks()

    perkKeys = (perk.properties.key.options.dataLocation() for perk in perks)

    perkNames = for perkKey in perkKeys
      namespace = "LandsOfIllusions.Character.Behavior.Perk.#{perkKey}"
      translation = AB.Translation.documents.findOne {namespace, key: 'name'}

      AB.translate(translation).text

    perkNames.join ', '
