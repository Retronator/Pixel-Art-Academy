LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Immigration extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration'
  @url: -> 'spaceport/immigration'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "immigration area"
  @shortName: -> "immigration"
  @description: ->
    "
      You are in front of the immigration checkpoint that lines its counters in the east.
      The airport terminal concourse leads towards the gates in the west.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
    RS.AirportTerminal.Immigration.Terminal
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Concourse
