LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Dock extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Dock'
  @url: -> 'spaceport/airship-dock'
  @region: -> RS

  @version: -> '0.0.1'

  @fullName: -> "airship dock"
  @shortName: -> "dock"
  @description: ->
    "
      You are on an elevated platform that extends from the terminal away over the hillside.
      From the main platform, smaller piers allow access to individual airships.
    "
  
  @initialize()

  constructor: ->
    super arguments...

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": RS.AirshipTerminal.Terminal
    "#{Vocabulary.Keys.Directions.In}": RS.AirshipTerminal.Terminal
