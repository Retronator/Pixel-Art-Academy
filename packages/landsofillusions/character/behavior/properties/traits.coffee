LOI = LandsOfIllusions

class LOI.Character.Behavior.Personality.Traits extends LOI.Character.Part.Property.Array
  toString: ->
    traits = @parts()
    return unless traits.length

    enabledTraits = _.filter traits, (trait) -> trait.properties.weight.options.dataLocation() > 0

    # TODO: Replace with translated names.
    traitNames = (_.capitalize trait.properties.key.options.dataLocation() for trait in enabledTraits)

    traitNames.join ', '
