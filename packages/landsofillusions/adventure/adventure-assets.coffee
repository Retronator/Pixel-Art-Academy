AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeAssets: ->
    # Subscribe to all character part templates.
    types = LOI.Character.Part.Types.Avatar.allPartTypeIds()

    LOI.Character.Part.Template.forTypes.subscribe @, types
