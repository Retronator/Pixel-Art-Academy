LOI = LandsOfIllusions

class LOI.Character.Behavior.Perks extends LOI.Character.Part.Property.Array
  activePerks: ->
    # TODO: filter parts to get only the ones that satisfy the requirements.
    @parts()
