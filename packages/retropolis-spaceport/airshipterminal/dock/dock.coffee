LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Dock extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Dock'
  @url: -> 'spaceport/airship-dock'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airship dock"
  @shortName: -> "dock"
  @description: ->
    "
      You are on an elevated platform that extends from the airship terminal building away over the hillside.
      From the main platform, three smaller piers allow access to individual airships.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": RS.AirshipTerminal.Terminal
