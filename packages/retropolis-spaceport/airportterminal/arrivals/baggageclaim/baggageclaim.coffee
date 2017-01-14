LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.BaggageClaim extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.BaggageClaim'
  @url: -> 'spaceport/baggage-claim'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airport terminal baggage claim"
  @shortName: -> "baggage claim"
  @description: ->
    "
      A single baggage carousel is bringing in luggage from the arrived flight. A way to pass the time while you wait
      is to look at informational displays that are explaining the rules of posessing physical things in Retropolis.
      After you've collected your suitcase, you can continue through the customs in the north.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": RS.AirportTerminal.Customs
