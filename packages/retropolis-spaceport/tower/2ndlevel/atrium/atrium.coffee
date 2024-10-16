LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.Tower.Atrium2ndLevel extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.Tower.Atrium2ndFloor'
  @url: -> 'spaceport/atrium/2nd-level'
  @region: -> RS

  @version: -> '0.0.1'

  @fullName: -> "Spaceport atrium, 2nd level"
  @shortName: -> "atrium"
  @description: ->
    "
      You are on the 2nd level of the atrium at the Retropolis International Spaceport. It's the main hub of the
      tower and leads around various departments. Escalators lead up
      and down to 1st and 3rd level of the tower. It's all pretty overwhelming.
    "
  
  @initialize()

  constructor: ->
    super arguments...

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": RS.AirportTerminal.Arrivals
    "#{Vocabulary.Keys.Directions.Southwest}": RS.AirportTerminal.Departures
    "#{Vocabulary.Keys.Directions.Southeast}": RS.AirshipTerminal.Terminal
