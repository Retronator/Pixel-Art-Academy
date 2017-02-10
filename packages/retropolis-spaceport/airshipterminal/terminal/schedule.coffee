LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Terminal.Schedule extends LOI.Adventure.Item
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terminal.Schedule'
  @fullName: -> "airships schedule"
  @shortName: -> "schedule"
  @description: ->
    "
      It's a display listing arrival and departure times of various airships.
    "

  @initialize()
