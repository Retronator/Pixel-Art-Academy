LOI = LandsOfIllusions

# Same as color, but inherited to show different color UI.
class LOI.Character.Avatar.Properties.OutfitColor extends LOI.Character.Avatar.Properties.Color
  constructor: (@options = {}) ->
    super arguments...

    @type = 'outfitColor'
