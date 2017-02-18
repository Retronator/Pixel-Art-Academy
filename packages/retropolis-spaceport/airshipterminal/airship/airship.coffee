LOI = LandsOfIllusions
RS = Retropolis.Spaceport

class RS.AirshipTerminal.Airship extends LOI.Adventure.Item
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Airship'
  @fullName: -> "airship"
  @description: ->
    "
      It's a whale-shaped hybrid airship, taking passengers from the Spaceport to Retropolis.
    "

  @initialize()
