LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Terminal.RoutesMap extends LOI.Adventure.Item
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terminal.RoutesMap'
  @fullName: -> "airship routes map"
  @shortName: -> "routes map"
  @description: ->
    "
      It's a display showing possible destinations in Retropolis.
    "

  @initialize()
