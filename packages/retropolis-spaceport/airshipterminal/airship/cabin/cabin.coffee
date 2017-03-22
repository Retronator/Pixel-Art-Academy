LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Airship.Cabin extends LOI.Adventure.Location
  @id: -> 'Retropolis.AirshipTerminal.Airship.Cabin'
  @url: -> 'airship/cabin'

  things: -> [
    RS.AirshipTerminal.Airship.Cabin.TableDisplay
  ]

  @version: -> '0.0.1'

  @fullName: -> "airship cabin"
  @description: ->
    "
      The interior of the airship is more like a spacious train carriage than a crammed airplane.
      The windows are generous in size as well. Observation seats run along the windows,
      while seats with tables allow people to work in the center.
    "
  
  @initialize()
