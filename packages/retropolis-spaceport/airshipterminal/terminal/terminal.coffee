LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Terminal extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terminal'
  @url: -> 'spaceport/airship-terminal'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airship terminal"
  @description: ->
    "
      The long hallway connects the main tower to a docking platform further southeast.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": RS.Tower.Atrium2ndLevel
    "#{Vocabulary.Keys.Directions.Southwest}": RS.AirshipTerminal.Dock
