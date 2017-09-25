LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Terminal.RoutesMap extends LOI.Adventure.Item
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terminal.RoutesMap'
  @fullName: -> "airship routes map"
  @shortName: -> "map"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      It's a display showing possible destinations in Retropolis.
    "

  @initialize()
