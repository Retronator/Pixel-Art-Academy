LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Security extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Security'
  @url: -> 'spaceport/security'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airport terminal security checkpoint"
  @shortName: -> "security"
  @description: ->
    "
      You are in the security checkpoint queue waiting to enter the airport terminal concourse.
      The line is clear to proceed through the scanners in the west or you can return east or southeast to the
      departures hall.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Security.Scanner
    "#{Vocabulary.Keys.Directions.East}": RS.AirportTerminal.Departures
    "#{Vocabulary.Keys.Directions.Southeast}": RS.AirportTerminal.CheckIn
