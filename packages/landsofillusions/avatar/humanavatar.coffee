AM = Artificial.Mummification
LOI = LandsOfIllusions

# Game representation of a human.
class LOI.HumanAvatar extends LOI.Avatar
  constructor: (@options) ->
    super
    
    @body = LOI.Character.Part.Types.Body.create
      dataLocation: new AM.Hierarchy.Location
        rootField: @options.bodyDataField

    @outfit = LOI.Character.Part.Types.Outfit.create
      dataLocation: new AM.Hierarchy.Location
        rootField: @options.outfitDataField
