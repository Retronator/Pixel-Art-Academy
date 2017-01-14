LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.CheckIn extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.CheckIn'
  @url: -> 'spaceport/check-in'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airport terminal check-in"
  @shortName: -> "check-in"
  @description: ->
    "
      Only a couple of airlines are present at the airport at any time so the check-in area sports a short counter with
      a few employees going on about their business. You can return to the hall in the north or skip to security
      north-west.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": RS.AirportTerminal.Departures
    "#{Vocabulary.Keys.Directions.Northwest}": RS.AirportTerminal.Security
