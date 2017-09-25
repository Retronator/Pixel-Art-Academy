LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Customs extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Customs'
  @url: -> 'spaceport/customs'
  @region: -> RS

  @version: -> '0.0.1'

  @fullName: -> "airport terminal customs"
  @shortName: -> "customs"
  @description: ->
    "
      The customs area is unlike anything you've experienced before. The X-ray machines automatically categorize
      all the items in your bags and you sign the contents list before you pass. The way out is north to the
      arrivals hall.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": RS.AirportTerminal.Arrivals
    "#{Vocabulary.Keys.Directions.South}": RS.AirportTerminal.BaggageClaim
