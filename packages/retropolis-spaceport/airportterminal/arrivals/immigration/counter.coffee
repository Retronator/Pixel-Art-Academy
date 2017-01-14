LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Immigration.Counter extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration.Counter'
  @url: -> 'spaceport/immigration/counter'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "immigration counter"
  @shortName: -> "counter"
  @description: ->
    "
      At the counters, officers are checking passengers' immigration documents. You can return back to the immigration area in the west.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
    RS.AirportTerminal.Immigration.Officer
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Immigration
