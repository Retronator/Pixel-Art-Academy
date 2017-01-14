LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Security.Scanner extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Security.Scanner'
  @url: -> 'spaceport/security/scanner'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airport terminal security scanner"
  @shortName: -> "scanner"
  @description: ->
    "
      You pass through the metal detector and get your inventory scanned. There is no way back and you have to
      exit to the concourse in the west.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Concourse
