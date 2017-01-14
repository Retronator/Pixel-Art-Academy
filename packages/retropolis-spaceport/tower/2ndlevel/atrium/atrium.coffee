LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Atrium2ndLevel extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Atrium2ndFloor'
  @url: -> 'spaceport/atrium/2nd-level'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "Spaceport atrium, 2nd level"
  @shortName: -> "atrium"
  @description: ->
    "
      You are on the 2nd level of the atrium at the Retropolis International Spaceport. It's the main hub of the
      tower that and its circular elevated pathway leads around the various departments. Escalators also lead up
      and down to 1st and 3rd level of the tower. It's all pretty overwhelming.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": RS.AirportTerminal.Arrivals
    "#{Vocabulary.Keys.Directions.Southwest}": RS.AirportTerminal.Departures
