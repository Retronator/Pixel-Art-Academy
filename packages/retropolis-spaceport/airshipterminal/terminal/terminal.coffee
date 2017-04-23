LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirshipTerminal.Terminal extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terminal'
  @url: -> 'spaceport/airship-terminal'
  @region: -> RS

  @version: -> '0.0.1'

  @fullName: -> "airship terminal"
  @description: ->
    "
      You enter the airship terminal. The long hallway connects the main tower to a docking platform further southeast.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
    RS.AirshipTerminal.Terminal.RoutesMap
    RS.AirshipTerminal.Terminal.Schedule
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": RS.Tower.Atrium2ndLevel
    "#{Vocabulary.Keys.Directions.Southeast}": RS.AirshipTerminal.Dock
