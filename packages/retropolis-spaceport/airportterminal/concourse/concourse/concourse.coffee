LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Concourse extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Concourse'
  @url: -> 'spaceport/concourse'

  @version: -> '0.0.1'

  @fullName: -> "airport terminal concourse"
  @shortName: -> "concourse"
  @description: ->
    "
      The airport terminal is quiet and cozy with only a few dozen people transferring from airplanes towards
      the arrivals area in the east. A terrace in the west overlooks the main island with a magnificent view.
      Escalators lead down to the airport gates.
    "
  
  @initialize()

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Terrace
    "#{Vocabulary.Keys.Directions.Out}": RS.AirportTerminal.Terrace
    "#{Vocabulary.Keys.Directions.East}": RS.AirportTerminal.Immigration
    "#{Vocabulary.Keys.Directions.Down}": RS.AirportTerminal.Gates
