LOI = LandsOfIllusions

class LOI.Character.Behavior.Personality.Traits extends LOI.Character.Part.Property.Array
  setTrait: (key, weight) ->
    traits = @parts()
    existingTrait = null

    if traits
      # See if we have an existing trait.
      existingTrait = _.find traits, (trait) => trait.properties.key.options.dataLocation() is key

    if existingTrait
      # Modify the weight of existing trait.
      existingTrait.properties.weight.options.dataLocation weight

    else
      # Create a new entry.
      traitType = LOI.Character.Part.Types.Behavior.Personality.Trait.options.type
      traitPart = @newPart traitType
      traitPart.options.dataLocation {key, weight}
    
  toString: ->
    traits = @parts()
    return unless traits.length

    enabledTraits = _.filter traits, (trait) -> trait.properties.weight.options.dataLocation() > 0

    # TODO: Replace with translated names.
    traitNames = (_.capitalize trait.properties.key.options.dataLocation() for trait in enabledTraits)

    traitNames.join ', '
