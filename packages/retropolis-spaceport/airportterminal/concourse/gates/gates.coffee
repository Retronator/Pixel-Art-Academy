LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Gates extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Gates'
  @url: -> 'spaceport/gates'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "Airport terminal gate"
  @shortName: -> "gates"
  @description: ->
    "
      You are at the airport gates that allow passengers to board the planes. All doors are closed as the
      staff prepares for the upcoming flights. Escalators in the east can take you a few stories higher to the
      main concourse.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.East}": RS.AirportTerminal.Concourse
    "#{Vocabulary.Keys.Directions.Up}": RS.AirportTerminal.Concourse
